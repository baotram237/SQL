-- Challenges
-- Question 1: What's the lowest replacement cost?
SELECT MIN(replacement_cost) AS lowest_rpl_cost
FROM film;

-- Question 2: How many films have a replacement cost in the "low" group?
/*Write a query that gives an overview of how many films have replacements costs in the following cost ranges

low: 9.99 - 19.99

medium: 20.00 - 24.99

high: 25.00 - 29.99*/

SELECT 
	CASE 
	WHEN replacement_cost BETWEEN 9.99 AND 19.99
	THEN 'low'
	WHEN replacement_cost BETWEEN 20 AND 24.99
	THEN 'medium'
	ELSE 'high'
END as cost_range,
COUNT(*)
FROM film
GROUP BY cost_range
HAVING cost_range = 'low';

-- other way
SELECT 
	SUM(CASE WHEN replacement_cost BETWEEN 9.99 and 19.99
	THEN 1
	ELSE 0 END) AS low_rpl_cost_film
FROM film;

-- Question 3: In which category is the longest film and how long is it?
SELECT c.name, f.title, f.length
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
ORDER BY f.length DESC
LIMIT 1

-- Question 4: Which category (name) is the most common among the films?
SELECT COUNT(*) AS num_film,
	 c.name
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
GROUP BY c.category_id
ORDER BY COUNT(*) DESC
LIMIT 1;

-- Question 5: Which actor is part of most movies??
SELECT ac.first_name, ac.last_name, COUNT(f.film_id) AS num_film
FROM actor ac
JOIN film_actor fc
ON ac.actor_id = fc_id
JOIN film f
ON fc.film_id = f.film_id
GROUP BY ac.actor_id
ORDER BY COUNT(f.film_id) DESC
LIMIT 1;

-- Question 6: Create an overview of the addresses that are not associated to any customer. 
-- How many addresses are that?
SELECT COUNT(*)
FROM address ad
LEFT JOIN customer c
on ad.address_id = c.address_id
WHERE customer_id IS NULL

-- Question 7: Which city has the most sales?
SELECT ci.city, SUM(p.amount) AS sales
FROM city ci
JOIN address ad
ON ci.city_id = ad.city
JOIN customer c
ON ad.address_id = c.address_id
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY ad.city_id
ORDER BY SUM(p.amount) DESC
LIMIT 1;

-- Question 8: Which country, city has the least sales?
SELECT co.country, ci.city, SUM(p.amount) AS sales
FROM country co
JOIN city ci
ON co.country_id = ci.country_id
JOIN address ad
ON ci.city_id = ad.city
JOIN customer c
ON ad.address_id = c.address_id
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY co.country_id, ci.city_id
ORDER BY SUM(p.amount) ASC
LIMIT 1

-- Question 9: Which staff_id makes on average more revenue per customer?
SELECT p.staff_id, ROUND(AVG(sale_each_cus),2)
FROM 
	(SELECT p.
		staff_id, 
		SUM(p.amount) AS sale_each_cus,
		p.customer_id
	FROM payment p
	GROUP BY p.staff_id, p.customer_id) AS revernue_per_cus
GROUP BY p.staff_id
ORDER BY AVG(sale_each_cus) DESC

-- Question 10: What is the daily average revenue of all Sundays?
SELECT AVG(total) 
FROM
	(SELECT SUM(amount) AS total, 
		DATE(payment_date) AS payment_date
	FROM payment
	WHERE EXTRACT(DOW FROM payment_date) AS = 0
	GROUP BY DATE(payment_date)) AS sundays

-- Question 11: Create a list of movies - with their length and their replacement cost 
-- that are longer than the average length in each replacement cost group. 
-- Which two movies are the shortest on that list and how long are they?

SELECT f1.title, f1.length, f1.replacement_cost
FROM film f1
WHERE f1.length >
				(SELECT AVG(f2.length) AS average
				FROM film f2
				WHERE f1.replacement_cost = f2.replacement_cost)
ORDER BY f1.length ASC, 
LIMIT 2

-- Question 12: Which district has the highest average customer lifetime value?
SELECT district, 
	AVG(total) AS avg_lifetime_value
FROM
	(SELECT SUM(p.amount) AS total, 
			customer_id
	FROM payment p
	JOIN customer c
	ON c.customer_id = p.customer_id
	JOIN address ad
	ON c.address_id = ad.address_id
	GROUP BY ad.district, p.customer_id) AS lifetime_value
GROUP BY district
ORDER BY AVG(lifetime_value.total) DESC 
LIMIT 1

-- Question 13: Create a list that shows all payments including the payment_id, amount, and the film category (name) 
-- plus the total amount that was made in this category. Order the results ascendingly by the category (name) 
-- and as second order criterion by the payment_id ascendingly.
SELECT p.payment_id, 
		p.amount, 
		ca.name,
		(SELECT SUM(p.amount) AS total_revenue
		FROM payment p
		JOIN rental re
		ON re.staff_id = st.staff_id
		JOIN inventory in
		ON re.inventory_id = in.inventory_id
		JOIN film f
		ON re.film_id = f.film_id
		JOIN film_category fc
		ON f.film_id = fc.film_id
		JOIN category ca1
		ON fc.category_id = ca1.category_id
		GROUP BY ca1.name
		WHERE ca1.name = ca2.name)
FROM payment p
		JOIN rental re
		ON re.staff_id = st.staff_id
		JOIN inventory in
		ON re.inventory_id = in.inventory_id
		JOIN film f
		ON re.film_id = f.film_id
		JOIN film_category fc
		ON f.film_id = fc.film_id
		JOIN category ca2
		ON fc.category_id = ca2.category_id
ORDER BY ca2.name ASC, p.payment_id ASC

-- Question 14: Create a list with the top overall revenue of a film title (sum of amount per title) for each category (name).
-- Which is the top-performing film in the animation category?
SELECT
title,
name,
SUM(amount) as total
FROM payment p
LEFT JOIN rental r
ON r.rental_id=p.rental_id
LEFT JOIN inventory i
ON i.inventory_id=r.inventory_id
LEFT JOIN film f
ON f.film_id=i.film_id
LEFT JOIN film_category fc
ON fc.film_id=f.film_id
LEFT JOIN category c
ON c.category_id=fc.category_id
GROUP BY name,title
HAVING SUM(amount) =     (SELECT MAX(total)
			  FROM 
                                (SELECT
			          title,
                                  name,
			          SUM(amount) as total
			          FROM payment p
			          LEFT JOIN rental r
			          ON r.rental_id=p.rental_id
			          LEFT JOIN inventory i
			          ON i.inventory_id=r.inventory_id
				  LEFT JOIN film f
				  ON f.film_id=i.film_id
				  LEFT JOIN film_category fc
				  ON fc.film_id=f.film_id
				  LEFT JOIN category c1
				  ON c1.category_id=fc.category_id
				  GROUP BY name,title) sub
			   WHERE c.name=sub.name)