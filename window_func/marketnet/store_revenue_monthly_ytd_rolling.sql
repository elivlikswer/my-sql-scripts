-- финансовый аналитик хочет отчёт по динамике выручки магазинов.
WITH report_store_YYYY_MM_revenue AS
(
	SELECT
		s.store_id,
		store_name,
		to_char(purchase_date, 'YYYY-MM') AS date,
		EXTRACT(YEAR FROM purchase_date) AS year_num,
		SUM(final_price) AS total_revenue
		
	FROM store s
	INNER JOIN purchase p ON s.store_id = p.store_id
	INNER JOIN purchase_product p_p ON p.purchase_id = p_p.purchase_id
	GROUP BY s.store_id, store_name, date, year_num
)

SELECT
	store_id,
	store_name,
	date,
	total_revenue,
	SUM(total_revenue) OVER(PARTITION BY store_id, year_num ORDER BY date ASC) AS sliding_window_sum,
	ROUND(AVG(total_revenue) OVER(PARTITION BY store_id ORDER BY date ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS avg_sliding_window_last_3
FROM report_store_YYYY_MM_revenue
	