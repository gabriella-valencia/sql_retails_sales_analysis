--1. DATABASE SETUP
--SQL Retail Analysis - P1
CREATE DATABASE sql_project_p2

--create TABLE
DROP TABLE IF EXISTS retails_sales;
CREATE TABLE retail_sales
			(
				transactions_id	INT PRIMARY KEY,
				sale_date DATE,	
				sale_time TIME,	
				customer_id	INT,
				gender VARCHAR(15),
				age	INT,
				category VARCHAR(15),	
				quantity	INT,
				price_per_unit FLOAT,	
				cogs FLOAT,	
				total_sale FLOAT
			);

SELECT * FROM retail_sales


--2. DATA CLEANING
--Check all the rows if there is null value or not, except age
SELECT * FROM public.retail_sales
WHERE 
	transactions_id IS NULL 
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL

--Delete the data that meet the conditions
DELETE FROM retail_sales
WHERE
transactions_id IS NULL 
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL


--3. DATA EXPLORATION
--a. How many sales do we have?
SELECT COUNT(*) AS total_sale FROM public.retail_sales

--b. How many unique customers do we have?
SELECT COUNT(DISTINCT customer_id) AS unique_customer_count FROM public.retail_sales

--c. What are the categories present?
SELECT DISTINCT category AS unique_category FROM public.retail_sales


--4. DATA ANALYSIS & BUSINESS KEY PROBLEMS & ANSWERS
SELECT * FROM public.retail_sales

--My analysis & Findings
--a. Write a SQL query to retrieve all columns for sales made on '2022-11-05'
SELECT * FROM public.retail_sales WHERE sale_date ='2022-11-05'

--b. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
SELECT * FROM public.retail_sales WHERE category = 'Clothing' 
AND quantity >= 4
AND TO_CHAR(sale_date,'YYYY-MM') ='2022-11'


--c. Write a SQL query  to calculate the total sales (total_sale) for each category.
SELECT category, SUM(total_sale) AS total_sale, COUNT(*) AS total_orders FROM public.retail_sales
GROUP BY category
ORDER BY 2,3

--d. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT ROUND(AVG(age)) AS average_age FROM public.retail_sales WHERE category = 'Beauty'

--e. Write a SQL query to find all transactions where the total_sale is greater than 1000
SELECT * FROM public.retail_sales WHERE total_sale > 1000

--f. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT category, gender, COUNT(transactions_id) AS total_transactions FROM public.retail_sales
GROUP BY category, gender
ORDER BY total_transactions

--g. Write a SQL query to calculate the average sale for each month. Find out the best selling month in each year.
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', sale_date) AS sale_month,
        DATE_PART('year', sale_date) AS sale_year, 
        ROUND(AVG(total_sale)::numeric, 2) AS average_total_sale
    FROM public.retail_sales
    GROUP BY 1, 2
)
SELECT sale_year, sale_month, average_total_sale
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY sale_year ORDER BY average_total_sale DESC) AS rank
    FROM monthly_sales
) ranked_sales
WHERE rank = 1
ORDER BY sale_year;


--h. Write a SQL query to find the top 5 customers based on the highest total sales
WITH sale_per_customer AS
(SELECT customer_id, SUM(total_sale) as sale FROM public.retail_sales
GROUP BY 1
ORDER BY sale),

sale_rank AS
(SELECT *, DENSE_RANK()OVER(ORDER BY sale DESC) AS 
dense_rank FROM sale_per_customer)

SELECT customer_id, sale FROM sale_rank WHERE dense_rank<=5

--i. Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT category, COUNT(DISTINCT customer_id) FROM public.retail_sales
GROUP BY 1
ORDER BY 2

--j. Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 13&17, Evening > 17)
SELECT 
CASE
	WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
	WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 and 17 THEN 'Afternoon'
	WHEN EXTRACT(HOUR FROM sale_time) > 17 THEN 'Evening'
END as shift,
COUNT(*) AS number_of_orders
FROM public.retail_sales
GROUP BY 1
ORDER BY 2

--END OF PROJECT
