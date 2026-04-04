------------------------------------------------------------------------------
--TASK 4--
SELECT COUNT(*) AS customers_count FROM customers;
--TASK 5--
-------------------------------------------------------------------------------
SELECT
-- TOP_10_TOTAL_INCOME --
	--получаем имя, фамилию продавца
	--количество совершённых продаж
	--общая выручка от продаж
	e.first_name || ' ' || e.last_name AS seller,
	COUNT(s.sales_id) AS operations,
	FLOOR(SUM(p.price * quantity)) AS income
FROM sales s
--соединяем таблицы по id-шкам
INNER JOIN employees e ON s.sales_person_id = e.employee_id
INNER JOIN products p ON p.product_id = s.product_id
--групируем по имени продавца
GROUP BY e.first_name, e.last_name
--сортируем по убыванию выручки продавца
ORDER BY income desc
LIMIT 10
;

WITH 
	-- сначала найдём общую стоимость средней сделки
	average_income_all AS (
	SELECT
		FLOOR(SUM(p.price * s.quantity)/COUNT(s.sales_id)) AS main_average_income
	FROM sales s
	INNER JOIN products p ON p.product_id = s.product_id 
	),
	averages AS (
	SELECT 
	-- LOWEST_AVERAGE_INCOME --
		e.first_name || ' ' || e.last_name AS seller,
		--получаем среднюю выручку продавца за сделку
		FLOOR(SUM(p.price * quantity)/COUNT(s.sales_id)) AS average_income
	FROM sales s
	INNER JOIN employees e ON s.sales_person_id = e.employee_id
	INNER JOIN products p ON p.product_id = s.product_id
	GROUP BY e.first_name, e.last_name
	)
-- теперь можем найти худших продавцов
SELECT
	seller,
	average_income
FROM average_income_all, averages
WHERE average_income < main_average_income
-- сортируем по возрастанию средней выручки продавца
ORDER BY average_income
;

SELECT 
-- DAY_OF_THE_WEEK_INCOME --
	e.first_name || ' ' || e.last_name AS seller,
    --преобразовываем дату в название дня недели
    REPLACE(LOWER(TO_CHAR(s.sale_date::DATE, 'Day')), ' ', '') AS day_of_week,
    FLOOR(SUM(p.price * quantity)) AS income
FROM sales s
INNER JOIN employees e ON s.sales_person_id = e.employee_id
INNER JOIN products p ON p.product_id = s.product_id
--групируем по имени и дню недели
GROUP BY
	e.first_name,
	e.last_name,
	TO_CHAR(s.sale_date, 'Day'),
	--это специальная функция, которая делает так, что бы день недели начинался с понедельника
    EXTRACT(ISODOW FROM s.sale_date)
--сортируем по дню недели и имени
ORDER by
	EXTRACT(ISODOW FROM s.sale_date),
	seller
;

--TASK 6--
-----------------------------------------------------------------------------------------------
SELECT 
-- AGE_GROUPS --
	-- оператор CASE с условиями для присвоения группы
	CASE
		WHEN age BETWEEN 16 AND 25 THEN '16-25'
		WHEN age BETWEEN 26 AND 40 THEN '26-40'
		WHEN age > 40 THEN '40+'
	END AS age_category,
	COUNT(*) as age_count
FROM customers
-- условия распределения возрастной группы
WHERE
	age BETWEEN 16 AND 25 OR
	age BETWEEN 26 AND 40 OR
	age > 40
GROUP BY age_category
ORDER BY age_category
;

SELECT 
-- CUSTOMERS_BY_MONTH --
	-- выделяем год и месяц,
	-- берём общее количество уникальных покупателей
	-- суммируем общую выручку
	TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
	COUNT(DISTINCT s.customer_id) AS total_customers,
	FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales s 
INNER JOIN products p ON p.product_id = s.product_id
--и групируем всё это дело по месячной выручке
GROUP BY selling_month
ORDER BY selling_month
;

WITH
-- SPECIAL_OFFER --
	-- создаём таблицу, где первая покупака была по акции
	-- т.е. p.price = 0
	main_sales_id AS (
		-- MIN в языке SQL первое значение
		-- благодаря группировке по "s.customer_id"
	    SELECT MIN(sales_id) AS main_id
	    FROM sales s 
	    INNER JOIN products p ON s.product_id = p.product_id 
	    WHERE p.price = 0
	    GROUP BY s.customer_id
	)
-- далее составляем основной запрос,
-- где создаём условие "main_sales_id m ON s.sales_id = m.main_id"
-- т.е. привязываем значения к id продаж, где первые покупки
-- покупателей были совершены по акции
SELECT 
    c.first_name || ' ' || c.last_name AS customer,
    s.sale_date,
    e.first_name || ' ' || e.last_name AS seller
FROM sales s
INNER JOIN customers c ON c.customer_id = s.customer_id
INNER JOIN employees e ON e.employee_id = s.sales_person_id
INNER JOIN products p ON p.product_id = s.product_id
INNER JOIN main_sales_id m ON s.sales_id = m.main_id
-- и группируем по id покупателей
ORDER BY c.customer_id;


-- SPECIAL_OFFER --
WITH rang AS (
    SELECT 
        s.customer_id,
        s.sale_date,
        s.sales_person_id,
        s.product_id,
        -- тут присваем номера строкам через оконную функцию, разбивая записи по "customer_id"
        -- и сортируем с самых первых дат
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.sale_date) AS rn
    FROM sales s
)
SELECT 
    c.first_name || ' ' || c.last_name AS customer,
    r.sale_date,
    e.first_name || ' ' || e.last_name AS seller
FROM rang r
JOIN products p ON p.product_id = r.product_id
JOIN customers c ON c.customer_id = r.customer_id
JOIN employees e ON e.employee_id = r.sales_person_id
-- описания главного условия: первая строка (т.е. первая покупка) с ценой 0
WHERE r.rn = 1 AND p.price = 0
ORDER BY c.customer_id;



