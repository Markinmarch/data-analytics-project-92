------------------------------------------------------------------------------
--TASK 4--
SELECT COUNT(*) AS customers_count FROM customers;
--TASK 5--
-------------------------------------------------------------------------------
SELECT
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

SELECT 
	e.first_name || ' ' || e.last_name AS seller,
	--получаем среднюю выручку продавца за сделку
	FLOOR(SUM(p.price * quantity)/COUNT(s.sales_id)) AS average_income
FROM sales s
INNER JOIN employees e ON s.sales_person_id = e.employee_id
INNER JOIN products p ON p.product_id = s.product_id 
GROUP BY e.first_name, e.last_name
--сортируем по возрастанию средней выручки продавца
ORDER BY average_income
;

SELECT
    e.first_name || ' ' || e.last_name AS seller,
    --преобразовываем дату в название дня недели
    TO_CHAR(s.sale_date::DATE, 'Day') AS day_of_week,
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
	-- оператор CASE с условиями для присвоения группы
	CASE
		WHEN age BETWEEN 16 AND 25 THEN '16-25'
		WHEN age BETWEEN 26 AND 40 THEN '26-40'
		WHEN age > 40 THEN '40+'
	END AS age_category,
	COUNT(*)
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

SELECT 
	--получаем имя покупателя,
	--дату продажи
	--и имя продавца
	c.first_name || ' ' || c.last_name AS customer,
	sale_date,
	e.first_name || ' ' || e.last_name AS seller
FROM sales s
INNER JOIN customers c ON c.customer_id = s.customer_id
INNER JOIN employees e ON e.employee_id = s.sales_person_id
INNER JOIN products p ON p.product_id = s.product_id
-- с условием, что цена товара была 0 денег, т.к. по акции
WHERE p.price = 0
;
	






























