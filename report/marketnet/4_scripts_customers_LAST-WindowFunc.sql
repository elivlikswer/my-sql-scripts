-- 1
-- 1(Cколько покупок совершено) в 2(каждом магазине) за всё время. Нужна таблица с названиями магазинов и количеством чеков (покупок).
-- Сортировка — по убыванию количества покупок, чтобы сразу увидеть самые активные точки.

SELECT
	store_name, 
	COUNT(p.purchase_id) AS num_of_purchases
FROM store s
INNER JOIN purchase p ON s.store_id = p.store_id
GROUP BY store_name
ORDER BY 2 DESC


-- 2
-- Финансовый директор хочет видеть не просто количество покупок, а денежный оборот (revenue) каждого магазина

SELECT
	s.store_name,
	SUM(final_price) AS total_revenue
FROM store s
INNER JOIN purchase pur ON s.store_id = pur.store_id
INNER JOIN purchase_product pur_pro ON pur.purchase_id = pur_pro.purchase_id
GROUP BY 1
ORDER BY 2 DESC

-- 3
-- Отдел маркетинга хочет запустить программу лояльности и просит список лучших клиентов по объёму покупок (в деньгах). 
-- Нужны (клиенты), потратившие больше 1000 (у.е.)^, с указанием их 1(полного имени) и 2(общей суммы).

SELECT
	CONCAT_WS(' ', last_name, first_name, middle_name) AS full_name,
	SUM(final_price) AS total_spent
FROM customer c
INNER JOIN purchase p ON c.customer_id = p.customer_id
INNER JOIN purchase_product p_p ON p.purchase_id = p_p.purchase_id
GROUP BY 1 HAVING SUM(final_price) > 1000
ORDER BY 2 DESC

-- 4 Маркетинг хочет запустить программу «VIP-клиенты» для тех, кто тратит больше среднего^.
--Нужен отчёт с: 1(Именем клиента), 2(Общей суммой покупок),
-- 3(Рангом клиента по убыванию суммы), 4 (Средней суммой покупок среди всех клиентов avg_spent)

WITH customer_sum AS
(
	SELECT
		c.customer_id,
		SUM(final_price) AS total_spent
	FROM customer c
	INNER JOIN purchase p ON c.customer_id = p.customer_id
	INNER JOIN purchase_product p_p ON p.purchase_id = p_p.purchase_id
	GROUP BY 1
)
,

over_avg_all AS
(
	SELECT AVG(total_spent) FROM customer_sum
),

customers_filter_sum_more_than_avg
AS
(
	SELECT *
	FROM customer_sum
	WHERE total_spent > (SELECT * FROM over_avg_all)
)
SELECT
	CONCAT_WS(' ', last_name, first_name, middle_name) AS full_name,
	total_spent,
	RANK() OVER(ORDER BY total_spent DESC) AS rank_cutomer,
	ROUND((SELECT * FROM over_avg_all),2) AS avg_spent
FROM customers_filter_sum_more_than_avg c_filter
INNER JOIN customer c ON c_filter.customer_id = c.customer_id
ORDER BY rank_cutomer