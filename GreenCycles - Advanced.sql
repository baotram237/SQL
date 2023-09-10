-- CHALLENGE 2: Window functions, grouping sets, rollups

-- Question 1: Write a query that returns the list of movies including: film_id, title, length, category
-- and average length of movies in that category. Order results by film_id
SELECT f.film_id, 
		f.title,
		f.length,
		ca.name AS category,
		ROUND(AVG(f.length) OVER (PARTITION BY ca.name),2) AS avg_length_in_category
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category ca
ON fc.category_id = ca.category_id
ORDER BY f.film_id

--Question 2: Write a query that returns all payment details including:
-- payment_id, customer_id, staff_id, rental_id, amount, payment_date
-- and the number of payments that were made by this customer with that amount.
-- order the results by payment_id
SELECT p.payment_id, 
		p.customer_id,
		p.staff_id,
		p.rental_id,
		p.amount,
		COUNT(*) OVER (PARTITION BY p.amount,p.customer_id) AS no_payments_with_that_amount
FROM payment p
ORDER BY payment_id

-- Question 3: Write a query that returns all the columns in payment table and the
-- running total amount of payment order by payment_date
SELECT *,
	SUM(amount) OVER(ORDER BY payment_date)
FROM payment

-- Combine with partition by clause
SELECT *,
	SUM(amount) OVER(PARTITION BY customer_id 
					ORDER BY payment_date, payment_id)
FROM payment

-- Rank() function
SELECT f.title,
		ca.name,
		f.length,
		RANK() OVER(PARTITION BY ca.name ORDER BY length DESC) AS len_rank_in_category
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category ca
ON fc.category_id = ca.category_id

-- Question 4: Write a query that returns the customers'name, the country and how many payments they have
-- Afterwards create a ranking of the top customers with most sales for each country. Filter 
-- the results to only the top 3 customers per country
SELECT *,
		RANK() OVER(PARTITION BY country ORDER BY no_payments DESC) AS rank_sales
FROM
	(SELECT c.first_name, 
			c.last_name,
			co.country AS country,
			COUNT (p.payment_id) AS no_payments
	FROM customer c
	JOIN payment p
	ON c.customer_id = p.customer_id
	JOIN address a
	ON c.address_id = a.address_id
	JOIN city ci
	ON a.city_id = ci.city_id
	JOIN country co
	ON ci.country_id = co.country_id
	GROUP BY c.first_name, 
				c.last_name,
				co.country) AS no_payments_per_cus
HAVING rank_sales <=3

-- Question 5: Write a query that returns the revenue of the day and 
-- the revenue of the previous day, order by the day.
-- Afterwards calculate the difference and the percentage 
-- growth compared to the previous day.
SELECT 
		SUM(amount), 
		payment_date,
		LAG(SUM(amount)) OVER (ORDER BY payment_date) AS previous_day,
		SUM(amount) - LAG(SUM(amount)) OVER (ORDER BY payment_date ASC) AS diffirence,
		ROUND(((LAG(SUM(amount)) OVER (ORDER BY payment_date ASC) - SUM(amount))/ SUM(amount))*100,2) AS percentage_growth
FROM payment
GROUP BY payment_date

-- Question 6: Write a query that return the sum of the amount for each customer
-- (first name and last name) and each staff_id. Also add the overall revenue per customer.
SELECT c.first_name,
		c.last_name,
		p.staff_id,
		SUM(p.amount) AS revenue
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY 
	GROUPING SETS (
					(c.first_name, c.last_name),
					(c.first_name, c.last_name, p.staff_id))
ORDER BY c.first_name, c.last_name, p.staff_id

-- Question 7: Write a query that calculates now the share of the revenue each staff_id makes per customer.
SELECT c.first_name,
		c.last_name,
		p.staff_id,
		SUM(p.amount) AS revenue,
		ROUND(SUM(p.amount)/FIRST_VALUE(SUM(amount)) 
								OVER (PARTITION BY first_name, last_name 
										ORDER BY SUM(amount) DESC)*100,2) AS Percentage
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY 
	GROUPING SETS (
					(c.first_name, c.last_name),
					(c.first_name, c.last_name, p.staff_id))
ORDER BY c.first_name, c.last_name, p.staff_id

-- Question 8: Write a query that calculates a booking amount rollup for the hierarchy
-- of quarter, month, week in month and day
SELECT EXTRACT(QUARTER FROM payment_date) AS Quarter,
		EXTRACT (MONTH FROM payment_date) AS Month,
		TO_CHAR(payment_date,'w') AS Week_in_month,
		payment_date AS day,
		COUNT(payment_id) as no_booking
FROM payment
GROUP BY 
	ROLLUP (EXTRACT(QUARTER FROM payment_date),
			EXTRACT (MONTH FROM payment_date),
			TO_CHAR(payment_date,'w'),
			payment_date)
ORDER BY 1,2,3,4
			
