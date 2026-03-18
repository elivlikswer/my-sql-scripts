-- Customer purchase numbering + quantity purchases
SELECT
	c.customer_id,
	p.purchase_id,
	purchase_date,
	ROW_NUMBER() OVER(PARTITION BY p.customer_id ORDER BY purchase_date) AS num_of_purchase,
	COUNT(c.customer_id) OVER (PARTITION BY p.customer_id) AS quantity_purchase
FROM customer c
INNER JOIN purchase p ON c.customer_id = p.customer_id


-- Share of product in the purchase price
SELECT
	purchase_id,
	product_id,
	final_price,
	SUM(final_price) OVER (PARTITION BY purchase_id)AS final_receipt,
	ROUND(final_price/SUM(final_price) OVER (PARTITION BY purchase_id)*100,2) || ' %' AS share_of_receipt
FROM purchase_product


-- Ranking products by price in a store
SELECT 
	store_id,
	product_id,
	current_price,
	DENSE_RANK() OVER(PARTITION BY store_id ORDER BY current_price DESC) AS rank_by_most_price
FROM product_store
ORDER BY 1,4
	

-- The previous price of the item in the store
WITH new_last_price AS
(
	SELECT 
		hp_id,
		product_id,
		store_id,
		date_price_change,
		new_price,
		LAG(new_price, 1) OVER(PARTITION BY product_id,store_id ORDER BY date_price_change) AS last_price
	FROM history_price
)
SELECT
	*,
	ABS(new_price-last_price) AS difference,
	CASE WHEN new_price-last_price < 0 THEN 'Понижение цены (↓)'
		 WHEN new_price-last_price > 1 THEN 'Повышение цены (↑)' 
		 WHEN new_price=last_price THEN 'Изменение цены в пределах от 0 до 1 (-)' 
		 WHEN new_price-last_price IS NULL THEN 'Данные отсутсвуют'
	END AS comment_of_difference
FROM new_last_price

