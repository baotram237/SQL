CREATE TABLE employees (
emp_id INT PRIMARY KEY,
first_name VARCHAR(25) NOT NULL,
last_name VARCHAR(25) NOT NULL,
job_position VARCHAR(20) NOT NULL,
salary DECIMAL(8,2),
start_date DATE NOT NULL,
birth_date DATE NOT NULL,
store_id INT,
department_id INT,
manager_id INT
)

CREATE TABLE departments(
department_id INT PRIMARY KEY,
department VARCHAR(25) NOT NULL,
division VARCHAR(25) NOT NULL
)

ALTER TABLE employees
ADD CONSTRAINT department_id_not_null CHECK(department_id IS NOT NULL)

ALTER TABLE employees
ADD CONSTRAINT start_date_df DEFAULT GETDATE() FOR start_date

ALTER TABLE employees
ADD end_date DATE

ALTER TABLE employees
ADD CONSTRAINT birth_check CHECK (birth_date < GETDATE())

INSERT INTO employees 
VALUES 
(1,'Morrie','Conaboy','CTO',21268.94,'2005-04-30','1983-07-10',1,1,1,NULL),
(2,'Miller','McQuarter','Head of BI',14614.00,'2019-07-23','1978-11-09',1,1,1,NULL),
(3,'Christalle','McKenny','Head of Sales',12587.00,'1999-02-05','1973-01-09',2,3,1,NULL),
(4,'Sumner','Seares','SQL Analyst',9515.00,'2006-05-31','1976-08-03',2,1,6,NULL),
(5,'Romain','Hacard','BI Consultant',7107.00,'2012-09-24','1984-07-14',1,1,6,NULL),
(6,'Ely','Luscombe','Team Lead Analytics',12564.00,'2002-06-12','1974-08-01',1,1,2,NULL),
(7,'Clywd','Filyashin','Senior SQL Analyst',10510.00,'2010-04-05','1989-07-23',2,1,2,NULL),
(8,'Christopher','Blague','SQL Analyst',9428.00,'2007-09-30','1990-12-07',2,2,6,NULL),
(9,'Roddie','Izen','Software Engineer',4937.00,'2019-03-22','2008-08-30',1,4,6,NULL),
(10,'Ammamaria','Izhak','Customer Support',2355.00,'2005-03-17','1974-07-27',2,5,3,'2013-04-14'),
(11,'Carlyn','Stripp','Customer Support',3060.00,'2013-09-06','1981-09-05',1,5,3,NULL),
(12,'Reuben','McRorie','Software Engineer',7119.00,'1995-12-31','1958-08-15',1,5,6,NULL),
(13,'Gates','Raison','Marketing Specialist',3910.00,'2013-07-18','1986-06-24',1,3,3,NULL),
(14,'Jordanna','Raitt','Marketing Specialist',5844.00,'2011-10-23','1993-03-16',2,3,3,NULL),
(15,'Guendolen','Motton','BI Consultant',8330.00,'2011-01-10','1980-10-22',2,3,6,NULL),
(16,'Doria','Turbat','Senior SQL Analyst',9278.00,'2010-08-15','1983-01-11',1,1,6,NULL),
(17,'Cort','Bewlie','Project Manager',5463.00,'2013-05-26','1986-10-05',1,5,3,NULL),
(18,'Margarita','Eaden','SQL Analyst',5977.00,'2014-09-24','1978-10-08',2,1,6,'2020-03-16'),
(19,'Hetty','Kingaby','SQL Analyst',7541.00,'2009-08-17','1999-04-25',1,2,6,NULL),
(20,'Lief','Robardley','SQL Analyst',8981.00,'2002-10-23','1971-01-25',2,3,6,'2016-07-01'),
(21,'Zaneta','Carlozzi','Working Student',1525.00,'2006-08-29','1995-04-16',1,3,6,'2012-02-19'),
(22,'Giana','Matz','Working Student',1036.00,'2016-03-18','1987-09-25',1,3,6,NULL),
(23,'Hamil','Evershed','Web Developper',3088.00,'2022-02-03','2012-03-30',1,4,2,NULL),
(24,'Lowe','Diamant','Web Developper',6418.00,'2018-12-31','2002-09-07',1,4,2,NULL),
(25,'Jack','Franklin','SQL Analyst',6771.00,'2013-05-18','2005-10-04',1,2,2,NULL),
(26,'Jessica','Brown','SQL Analyst',8566.00,'2003-10-23','1965-01-29',1,1,2,NULL)

INSERT INTO departments
VALUES 
(1,'Analytics','IT'),
(2,'Finance','Administration'),
(3,'Sales','Sales'),
(4,'Website','IT'),
(5,'Back Office','Administration')

UPDATE employees
SET job_position = 'Senior SQL Analyst', salary = 7200
WHERE first_name = 'Jack' AND last_name = 'Franklin'

UPDATE employees
SET job_position = 'Customer Specialist'
WHERE job_position = 'Customer Support'

UPDATE employees
SET salary = salary * 1.06
WHERE job_position = 'SQL Analyst' OR job_position = 'Senior SQL Analyst'

-- What is the average salary of a SQL Analyst 
-- in the company (excluding Senior SQL Analyst)?

SELECT ROUND(AVG(salary),2)
FROM employees
WHERE job_position = 'SQL Analyst'

-- Challenge
-- Question 1: Write a query that adds a column called manager 
-- that contains  first_name and last_name (in one column) in the data output.

-- Secondly, add a column called is_active with 'false' if the employee has left the company already, 
-- otherwise the value is 'true'.

SELECT emp.*,
	mng.first_name +' '+ mng.last_name AS manager_name,
	CASE WHEN 
		emp.end_date IS NULL THEN 'true'
		ELSE 'false'
		END AS is_active
	FROM employees emp
	JOIN employees mng
	ON emp.manager_id = mng.emp_id

-- Question 2: Write a query that returns the average salaries for each positions with appropriate roundings.
-- Secondly, Write a query that returns the average salaries per division
SELECT job_position,
	ROUND(AVG(salary),2) AS avg_salary
FROM employees
GROUP BY job_position
ORDER BY AVG(salary) DESC

SELECT d.division,
		ROUND(AVG(e.salary),2) AS avg_salary
FROM employees e
JOIN departments d
ON e.department_id = d.department_id
GROUP BY d.division
ORDER BY ROUND(AVG(e.salary),2) DESC

-- Question 3: Write a query that returns the following: emp_id,
-- first_name, last_name, position_title, salary and a column that returns the average salary for every job_position.
-- Order the results by the emp_id.

SELECT emp_id,
		first_name,
		last_name,
		job_position,
		salary,
		ROUND(AVG(salary) OVER(PARTITION BY job_position),2) AS avg_position_salary
FROM employees
ORDER BY emp_id

-- Question 4: How many people earn less than their avg_position_salary?
-- Write a query that answers that question.
-- Ideally, the output just shows that number directly.

SELECT COUNT(*)
FROM employees e1
WHERE salary < (SELECT AVG(e2.salary)
				FROM employees e2
				WHERE e1.job_position = e2.job_position)

-- Question 5: Write a query that returns a running total of the salary development 
-- ordered by the start_date.
-- In your calculation, you can assume their salary has not changed over time, and you can disregard 
-- the fact that people have left the company (write the query as if they were still working for the company).

SELECT start_date,
	salary,
	SUM(salary) OVER (ORDER BY start_date ASC) AS running_salary
FROM employees
ORDER BY start_date ASC

-- Question 6: Create the same running total but now also consider the fact that people were leaving the company.
SELECT 
start_date,
salary,
SUM(salary) OVER(ORDER BY start_date)
FROM (
	SELECT 
	emp_id,
	salary,
	start_date
	FROM employees
	UNION 
	SELECT 
	emp_id,
	-salary AS salary,
	end_date
	FROM employees
	WHERE end_date IS NOT NULL) a 
-- Question 7: Write a query that outputs only the top earner per position_title including first_name 
-- and the job_postition and their salary
-- Then, add also the average salary per job_position
SELECT e1.first_name,
		e1.job_position,
		e1.salary,
		(SELECT ROUND(AVG(e2.salary),2) AS avg_in_pos
			FROM employees e2
			WHERE e1.job_position = e2.job_position)
FROM employees e1
WHERE e1.salary = (SELECT MAX(e3.salary)
						FROM employees e3
						WHERE e1.job_position=e3.job_position)
ORDER BY e1.salary DESC

-- Question 8: However, there are the people that are the only ones with their position_title.
-- Remove those from the output of the previous query
SELECT first_name,
		job_position,
		salary,
		(SELECT ROUND(AVG(e2.salary),2) AS avg_in_pos
			FROM employees e2
			WHERE e1.job_position = e2.job_position)
FROM employees e1
WHERE e1.salary = (SELECT MAX(e3.salary)
						FROM employees e3
						WHERE e1.job_position=e3.job_position)
AND salary <> (SELECT ROUND(AVG(e2.salary),2) AS avg_in_pos
			FROM employees e2
			WHERE e1.job_position = e2.job_position)
ORDER BY e1.salary DESC

-- Question 9: Write a query that returns all meaningful aggregations of:
-- sum of salary, number of employees, average salary
-- grouped by all meaningful combinations of division, department, job_position
-- consider the leveles of hierarchies in a meaningful way

SELECT d.division,
		d.department,
		e.job_position,
		SUM(e.salary) AS sum_of_salary,
		COUNT(e.emp_id) AS no_employees,
		ROUND(AVG(e.salary),2) AS avg_salary
FROM employees e
JOIN departments d
ON e.department_id = d.department_id
GROUP BY
	ROLLUP (d.division,d.department,e.job_position)
ORDER BY 1,2,3

-- Question 10: Write a query that returns all employees (emp_id) including their position_title, 
-- department, their salary, and the rank of that salary partitioned by department.
SELECT emp_id,
	job_position,
	department,
	salary,
	RANK() OVER(PARTITION BY department ORDER BY salary DESC) as rank
FROM employees e
JOIN departments d
ON e.department_id  =d.department_id
ORDER BY department, rank 

-- Question 11: Write a query that returns only the top earner of each department including
-- their emp_id, position_title, department, and their salary.
SELECT emp_id,
		job_position,
		department,
		salary
FROM
	(SELECT emp_id,
	job_position,
	d.department,
	salary,
	RANK() OVER(PARTITION BY department ORDER BY salary DESC) as rank
	FROM employees e
	JOIN departments d
	ON e.department_id  =d.department_id) AS ranking
WHERE rank = 1
ORDER BY salary DESC
