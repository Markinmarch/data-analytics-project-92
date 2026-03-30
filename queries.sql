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

