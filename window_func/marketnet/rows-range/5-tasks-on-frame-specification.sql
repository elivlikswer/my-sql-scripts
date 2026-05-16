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
WITH total_final_price_purchase AS
(
	SELECT
		p.purchase_id,
		p.purchase_date,
		SUM(final_price) AS revenue
	FROM purchase p
	INNER JOIN purchase_product pp ON p.purchase_id = pp.purchase_id
	GROUP BY 1,2
) -- добавлена CTE, чтобы в итоговой выборке не было дублей (так как для одного purchase повторялась запись ровно столько, сколько товаров в purchase)

SELECT
	purchase_id,
	purchase_date,
	SUM(revenue) OVER(ORDER BY purchase_date RANGE BETWEEN '2 days' PRECEDING AND CURRENT ROW) AS rolling_sum_2
FROM total_final_price_purchase tfpp
ORDER BY purchase_date,purchase_id ;

-- Задача 3 — Сравнение ROWS и RANGE на дубликатах
-- Найди даты, в которые было несколько покупок. Для каждой такой строки (покупки) посчитай:
-- 1) Среднюю сумму final_price по ровно трём предыдущим строкам (включая текущую) при упорядочивании по дате и purchase_id.
-- 2) Среднюю сумму по всем покупкам за тот же день (по значению даты).
WITH dates_have_purhases AS 
(
	SELECT purchase_date
	FROM purchase
	GROUP BY purchase_date
	HAVING COUNT(DISTINCT purchase_id) > 1
),-- исправление: вместо того, чтобы генерировать много дат для их последующей проверки, лучше определить в основной таблице наличие нескольких purchase_id за одну дату.

total_final_price_purchase AS
(
	SELECT
		p.purchase_id,
		p.purchase_date,
		SUM(final_price) AS revenue
	FROM purchase p
	INNER JOIN purchase_product pp ON p.purchase_id = pp.purchase_id
	GROUP BY 1,2
) -- добавлена CTE, чтобы в итоговой выборке не было дублей (так как для одного purchase повторялась запись ровно столько, сколько товаров в purchase)

SELECT
	purchase_id,
	dhp.purchase_date,
	ROUND(AVG(revenue) OVER(ORDER BY dhp.purchase_date, purchase_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS avg_final_price_3rows,
	ROUND(AVG(revenue) OVER(PARTITION BY dhp.purchase_date),2) AS avg_revenue_for_day
FROM total_final_price_purchase tfpp
INNER JOIN dates_have_purhases dhp ON tfpp.purchase_date = dhp.purchase_date