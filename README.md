# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  
**Database**: `sql_project_p2`

This project focuses on analyzing retail sales data to gain actionable business insights using SQL. It covers essential techniques such as data cleaning, exploratory data analysis (EDA), and business-driven SQL queries. The goal is to understand customer purchasing behavior, identify sales trends, and help businesses optimize strategies based on data-driven insights.


## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Analyze key metrics such as total sales, average order value, and product category distribution to identify trends in customer purchases.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `sql_project_p2`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE sql_project_p2;

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
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data (except for age column, since there are customers that buy the good, although they don't state their age).

```sql
SELECT COUNT(*) AS total_sale FROM public.retail_sales
SELECT COUNT(DISTINCT customer_id) AS unique_customer_count FROM public.retail_sales
SELECT DISTINCT category AS unique_category FROM public.retail_sales

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05'**:
```sql
SELECT * 
FROM public.retail_sales 
WHERE sale_date ='2022-11-05';
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
SELECT * 
FROM public.retail_sales 
WHERE 
    category = 'Clothing' 
    AND quantity >= 4
    AND TO_CHAR(sale_date,'YYYY-MM') ='2022-11';
```

3. **Write a SQL query  to calculate the total sales (total_sale) for each category.**:
```sql
SELECT category, 
SUM(total_sale) AS total_sale, 
COUNT(*) AS total_orders 
FROM public.retail_sales
GROUP BY category
ORDER BY 2,3;
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT 
ROUND(AVG(age)) AS average_age 
FROM public.retail_sales 
WHERE category = 'Beauty';
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000**:
```sql
SELECT * 
FROM public.retail_sales 
WHERE total_sale > 1000;
```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT 
    category, 
    gender, 
    COUNT(transactions_id) AS total_transactions 
FROM public.retail_sales
GROUP BY category, gender
ORDER BY total_transactions;

```

7. **Write a SQL query to calculate the average sale for each month. Find out the best selling month in each year.**:
```sql
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
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
```sql
WITH sale_per_customer AS
(SELECT customer_id, SUM(total_sale) as sale FROM public.retail_sales
GROUP BY 1
ORDER BY sale),

sale_rank AS
(SELECT *, DENSE_RANK()OVER(ORDER BY sale DESC) AS 
dense_rank FROM sale_per_customer)

SELECT customer_id, sale FROM sale_rank WHERE dense_rank<=5;
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT 
    category, 
    COUNT(DISTINCT customer_id) 
FROM public.retail_sales
GROUP BY 1
ORDER BY 2;
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
SELECT 
CASE
	WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
	WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 and 17 THEN 'Afternoon'
	WHEN EXTRACT(HOUR FROM sale_time) > 17 THEN 'Evening'
END as shift,
COUNT(*) AS number_of_orders
FROM public.retail_sales
GROUP BY 1
ORDER BY 2;
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with an average customer age of 40 years. In addition, sales are distributed across different categories such as Beauty, Clothing, and Electronics. 
- **High-Value Transactions**: Purchases exceeding $1000 indicate premium transactions. While Electronics contribute the highest total sales, the majority of orders come from the Clothing category.
- **Sales Trends**: Seasonal trends reveal peak sales periods. Retail sales peaked in July 2022 and February 2023.
- **Customer Insights**: The Clothing category attracts the most unique customers, but Electronics generate the highest revenue. As for top-spending customers, it include customer IDs 3, 1, 5, 2, and 4

## Reports

- **Sales Summary**: In 2022, sales began at 397.11 in January before declining slightly to 366.14 in February, marking one of the lowest recorded values in this dataset. However, sales rebounded in March (521.38), reaching one of the highest averages of the year. After this peak, sales decreased to 486.53 in April and continued to fluctuate moderately between 480.38 in May and 481.40 in June. Another notable increase occurred in July, reaching 541.34, the highest monthly average recorded in 2022. Following this peak, sales dropped to 385.36 in August before stabilizing between 478.84 (September) and 467.36 (October). The final two months of the year saw relatively steady values, with 472.02 in November and 464.20 in December.

In 2023, the year started with a lower average total sale of 396.50 in January. However, February experienced a sharp rise to 535.53, making it the highest recorded month of the year. Sales then declined to 394.81 in March and remained relatively stable in April (466.49) and May (450.17). From June to September, sales followed a downward trend, dropping from 438.48 (June) to 427.68 (July), and then increasing slightly to 495.96 in August before declining again to 462.74 in September. The last quarter of the year showed fluctuating sales, with 399.17 in October, a slight increase to 453.45 in November, and finishing the year at 490.39 in December.
- **Trend Analysis**: Insights into sales trends across different months and shifts(timing). Most customers create orders on Evening shift with the count of 1062.
- **Customer Insights**: The Clothing category attracts the most unique customers with the count of 149, but Electronics generate the highest revenue with total sale of 313810. As for top-spending customers, it comes from customer_id 3, 1, 5, 2, and 4.

## Conclusion

The analysis of retail sales data from 2022 to 2023 provides key insights into customer behavior, purchasing trends, and high-value transactions.

1. **Customer Behavior**: The majority of customers fall within an average age of 40, with purchases distributed across Beauty, Clothing, and Electronics. While Electronics contribute the highest total sales, the Clothing category attracts the largest number of unique customers.

2. **High-Value Transactions**: Premium purchases, defined as transactions exceeding $1000, are more frequent in the Electronics category, reinforcing its role as the primary revenue driver.

3. **Sales Trends**: Seasonal trends reveal that retail sales peaked in July 2022 and February 2023, indicating potential promotional periods or consumer behavior shifts. The highest number of orders was placed during the Evening shift (1062 orders), suggesting that customers are more active during this period.

4. **Revenue Distribution**: The Electronics category generated the highest revenue, totaling $313,810, while the Clothing category had the most unique customers (149). The top-spending customers were identified as customer_id 3, 1, 5, 2, and 4.

By leveraging these insights, businesses can strategically optimize marketing campaigns, enhance inventory planning, and adjust pricing models to maximize revenue. This project serves as a foundational example of how SQL-driven data analysis can provide meaningful business intelligence for retail decision-making.


## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `analysis_queries.sql` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author - Gabriella Valencia Lim
This project is part of my data analysis portfolio, inspired by Zero Analyst which can be accessed through this link (https://github.com/najirh/Retail-Sales-Analysis-SQL-Project--P1). Special thanks to Zero Analyst for providing the foundation for my first portfolio project.


