-- Бизнес-задача 1 — Rolling Retention Analysis
-- Маркетинг хочет понимать, как быстро клиенты возвращаются за повторными покупками.\
-- Нужно посчитать для каждого клиента интервалы между покупками и их накопленное среднее.
    -- customer_id,

    -- purchase_id,

    -- purchase_date,

    -- сумму покупки (сумма final_price всех товаров в чеке),

    -- дату предыдущей покупки этого клиента (prev_purchase_date),

    -- интервал в днях с предыдущей покупки (days_since_prev), для первой покупки — NULL,

    -- средний интервал между всеми предыдущими покупками клиента на момент текущей покупки (avg_interval_before_this).
	-- Не включай текущий интервал в этот средний.

WITH customer_purchase_total_by_dates AS
(	SELECT
		c.customer_id,
		p.purchase_id,
		purchase_date,
		SUM(final_price) AS total_sum_purchase,
		LAG(purchase_date,1,NULL) OVER(PARTITION BY customer_id ORDER BY purchase_date, purchase_id) AS prev_purchase_date
	FROM customer c 
	JOIN purchase p USING(customer_id)
	JOIN purchase_product pp USING(purchase_id)
	GROUP BY c.customer_id, p.purchase_id, purchase_date
),
interval_between_prev_current_purchases AS
(
	SELECT *,
	purchase_date::TIMESTAMP - prev_purchase_date::TIMESTAMP AS days_since_prev
	FROM customer_purchase_total_by_dates
)

SELECT
	*,
	AVG(days_since_prev) OVER(PARTITION BY customer_id ORDER BY purchase_date ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS avg_days_exact,
	ROUND(EXTRACT(EPOCH FROM (AVG(days_since_prev) OVER(PARTITION BY customer_id ORDER BY purchase_date ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING))/86400),2) avg_days_formatted 
FROM interval_between_prev_current_purchases
		
	