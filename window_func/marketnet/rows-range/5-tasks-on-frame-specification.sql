-- Небольшие задачи
-- "Advanced Window Functions - Frame Specification"

-- 1. Задача 1 — Физический фрейм (ROWS)
-- Для каждого товара выведи product_id и дату покупки, и посчитай скользящую сумму продаж (final_price) 
-- за последние 3 покупки этого товара, включая текущую, упорядоченные по дате покупки (и purchase_id для детерминизма).

SELECT
	pp.product_id,
	pp.purchase_id,
	purchase_date,
	final_price,
	SUM(final_price) OVER (PARTITION BY pp.product_id ORDER BY purchase_date, pp.purchase_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
FROM purchase p
INNER JOIN purchase_product pp ON p.purchase_id = pp.purchase_id;

-- Задача 2 — Логический фрейм (RANGE с интервалом)
-- Для каждой покупки (purchase_id) выведи purchase_date и сумму final_price всех покупок, 
-- совершённых в течение 2 дней до этой покупки (включая тот же день), независимо от количества строк.
SELECT
	pp.purchase_id,
	purchase_date,
	SUM(final_price) OVER(ORDER BY purchase_date RANGE BETWEEN '2 days' PRECEDING AND CURRENT ROW)
FROM purchase p
INNER JOIN purchase_product pp ON p.purchase_id = pp.purchase_id
ORDER BY purchase_date;

-- Задача 3 — Сравнение ROWS и RANGE на дубликатах
-- Найди даты, в которые было несколько покупок. Для каждой такой строки (покупки) посчитай:
-- 1) Среднюю сумму final_price по ровно трём предыдущим строкам (включая текущую) при упорядочивании по дате и purchase_id.
-- 2) Среднюю сумму по всем покупкам за тот же день (по значению даты).
WITH all_date AS
(
	SELECT generate_series
	(
		'2015-01-01'::timestamp,
		'2024-12-29'::timestamp,
		'1 day'::interval
	) AS date
)
SELECT
	pp.purchase_id
	purchase_date,
	ROUND(SUM(final_price)OVER(ORDER BY purchase_date, pp.purchase_id ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)/4,2) AS avg_sum_4_rows,
	ROUND(SUM(final_price) OVER(PARTITION BY purchase_date ORDER BY purchase_date, pp.purchase_id)/COUNT(pp.purchase_id)OVER(PARTITION BY purchase_date ORDER BY purchase_date, pp.purchase_id),2)
FROM purchase p
LEFT JOIN all_date ad ON p.purchase_date = ad.date
LEFT JOIN purchase_product pp ON p.purchase_id = pp.purchase_id 