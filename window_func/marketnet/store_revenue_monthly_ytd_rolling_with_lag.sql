-- дата-инженер настраивает ежемесячный отчёт для руководства. 
-- Требование: в отчёте должны присутствовать все месяцы за 2023 и 2024 год — даже если продаж не было. 
-- Для каждого месяца нужно показать:
-- 1. месяц в формате YYYY-MM
-- 2. количество уникальных покупок
-- 3. суммарную выручку (0 если продаж не было)
-- 4. выручку за предыдущий месяц (для сравнения)
-- 5. разницу с предыдущим месяцем
WITH all_months AS
(
	SELECT generate_series(
		'2023-01-01',
		'2024-12-31',
		INTERVAL '1 month'
	) AS current_month
),
monthly_revenue AS
(
	SELECT
		current_month,
		COUNT(DISTINCT p.purchase_id) AS unic_purchases,
		COALESCE(SUM(final_price),0) AS monthly_revenue
	FROM all_months am
	LEFT JOIN purchase p ON date_trunc('month',p.purchase_date) = am.current_month
	LEFT JOIN purchase_product pp ON p.purchase_id = pp.purchase_id
	GROUP BY current_month
),
monthly_revenue_with_lag AS
(
	SELECT
		TO_CHAR(current_month,'YYYY-MM'),
		unic_purchases,
		monthly_revenue,
		LAG(monthly_revenue) OVER(ORDER BY current_month) AS last_month_revenue
	FROM monthly_revenue mr
)
SELECT *,
	monthly_revenue - last_month_revenue AS diff_last_current_month
FROM monthly_revenue_with_lag


