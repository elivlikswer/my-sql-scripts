-- Менеджеры хотят понимать, как часто и на сколько меняются цены на товары в разных магазинах. 
-- Для этого нужно для каждого изменения цены в таблице history_price вычислить:
--     Предыдущую цену (цену до изменения);
--     Разницу в абсолютном и процентном выражении;
--     Следующую цену (цену после следующего изменения), чтобы видеть полную картину колебаний.


WITH hp_prev_price AS
(
	SELECT
		product_id,
		store_id,
		date_price_change,
		new_price,
		LAG(new_price) OVER(PARTITION BY product_id, store_id ORDER BY date_price_change) AS prev_price
	FROM history_price
)
SELECT
	*,
	new_price - prev_price AS price_diff,
	ROUND((new_price-prev_price) / NULLIF(prev_price,0)*100,2) AS price_diff_percent,
	LEAD(new_price) OVER(PARTITION BY product_id, store_id ORDER BY date_price_change) AS next_price
FROM hp_prev_price