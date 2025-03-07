--WE ARE GOING TO COMPUTE DIFFFERENT COMPLEX QUERIES TO BETTER UNDERSTAND OUR DATA

--WE ARE GOING TO OBSERVE THE CHANGE OVER TIME (TRENDS)
--formula for this is MEASURE by DATE DIMENSION

--ANALYZE SALES PERFORMANCE OVER TIME
SELECT
order_date, sales_amount
FROM gold.fact_sales
WHERE order_date IS NOT NULL
ORDER BY order_date

 --ANALYZE SALES PERFORMANCE OVER TIME
SELECT
order_date, 
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date


 --ANALYZE SALES PERFORMANCE OVER YEAR
SELECT
YEAR(order_date) AS order_year, 
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)

 --ANALYZE SALES PERFORMANCE AND TOTAL NUMBER OF CUSTOMER OVER YEAR 
SELECT
YEAR(order_date) AS order_year, 
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)

 --ANALYZE SALES PERFORMANCE AND TOTAL NUMBER OF CUSTOMER OVER MONTH 
SELECT
YEAR(order_date) AS order_year,
MONTH(order_date) AS order_month, 
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
--ORDER BY total_sales DESC
ORDER BY YEAR(order_date), MONTH(order_date)

 --ANALYZE SALES PERFORMANCE AND TOTAL NUMBER OF CUSTOMER OVER MONTH USING The dATETRUNC FORMULA
SELECT
DATETRUNC(month, order_date) as order_date,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date)

 --ANALYZE SALES PERFORMANCE AND TOTAL NUMBER OF CUSTOMER OVER MONTH USING The FORMAT FORMULA
SELECT
FORMAT(order_date, 'yyyy-MMM') as order_date,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM')


--===
--===CUMULATIVE ANALYSIS (Agg thedata progressively over time) knowing how our sales are doing over time
--=== Foemula: cumulative measure By Date Dimension


--Calculate the total sales per month
--and the running total of sales over time

SELECT order_date, total_sales,
--window function
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM
(
SELECT
DATETRUNC(month, order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
)t


--PARTITIONING BY month
SELECT order_date, total_sales,
--window function
SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales
FROM
(
SELECT
DATETRUNC(month, order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
)t



---=== FInd the moving average ===---
SELECT order_date, total_sales,
--window function
SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER (PARTITION BY order_date ORDER BY order_date) AS moving_average_price
FROM
(
SELECT
DATETRUNC(year, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
)t


----===   PERFORMANCE ANALYSIS   ===----
---Comparing the current value to a target value
---helps measure success and compare performance
---Current[Measure] - Target[Measure]



/* Analyze the yearly performance of products by comparing their salaes to both
the average sales performance of the product and the prev year's sales */


--THIS CODE GENERATEs THE YEARLY PERFORMANCE OF PRODUcTS 
SELECT 
YEAR(f.order_date) AS order_date,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_Date IS NOT NULL
GROUP BY YEAR(f.order_date), p.product_name


--THIS CODE GENERATEs THE YEARLY PERFORMANCE OF PRODUcTS PLUS THE AVG SALES PERFORMANCE OF THE PRD AND THE PRV YEAR"S SALE

--using CTE
WITH yearly_product_sales AS (
SELECT 
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_Date IS NOT NULL
GROUP BY YEAR(f.order_date), p.product_name
) 
SELECT  
order_year,
product_name,
current_sales,
AVG(current_Sales) OVER (PARTITION BY product_name) avg_sales
FROM yearly_product_sales
ORDER BY product_name, order_year


--using CTE to get extra values like difference in avg 
WITH yearly_product_sales AS (
SELECT 
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_Date IS NOT NULL
GROUP BY YEAR(f.order_date), p.product_name
) 
SELECT  
order_year,
product_name,
current_sales,
AVG(current_Sales) OVER (PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
	 ELSE 'Avg'
END avg_change,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
ELSE 'No Change'
END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year



--using CTE to get extra values like difference in avg 
WITH yearly_product_sales AS (
SELECT 
DATETRUNC(month, f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_Date IS NOT NULL
GROUP BY DATETRUNC(month, f.order_date), p.product_name
) 
SELECT  
order_year,
product_name,
current_sales,
AVG(current_Sales) OVER (PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
	 ELSE 'Avg'
END avg_change,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
ELSE 'No Change'
END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year



/*PART TO WHOLE ANALYSIS OR ---PROPORTIONAL ANALYSIS
WE use it in order to find out the proportion of a part relative to a whole
allowing us to understand which category has the greatest impact on the business
Forumula: ([measure]/total[measure]) * 100 By [Dimension]
*/

--Which categories contriute the most to the overall sales?
SELECT 
category, 
sales_amount 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key

--Which categories contriute the most to the overall sales? --getting a  clearer picture --zooming in
SELECT 
category, 
SUM(sales_amount) total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY category
ORDER BY total_sales DESC

--Which categories contriute the most to the overall sales? USING WINDOWS FUNCTION
--CTE
WITH category_sales AS (
SELECT 
category, 
SUM(sales_amount) total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY category )
SELECT 
category, 
total_sales,
SUM(total_sales) OVER () overall_Sales,
CONCAT(ROUND((CAST (total_sales AS FLOAT ) / SUM(total_Sales) OVER ())*100,2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_Sales DESC

/*
DATA SEGMENTATION...groruping data basaed on a specific range
helps understand the correlation between two measures
FORMULA --- measure by measure

--SEGMENT PRODUCTS INTO COST RANGES AND COUNT HOW MANY PRODUCTS FALL INTO EACH SEGMENT
*/

SELECT
product_key, product_name, cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 100 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range
FROM gold.dim_products

--ADDING CTE
WITH product_segments AS (
SELECT
product_key, product_name, cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 100 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range
FROM gold.dim_products ) SELECT 
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC


/* 
Group customers  into threee segments based on their spending behaviour:
 -VIP: Customers with at least 12 months of history and spending more than $5,000.
 -Regular: Customers with at least 12 monts of history but spending $5,000 or less.
 -New: Customers with a lifespan less than 12 months
 And find the total number of customers by each group
*/


SELECT
c.customer_key,
f.sales_amount,
f.order_date
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
ON f.customer_key = c.customer_key





SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
ON f.customer_key = c.customer_key
GROUP BY c.customer_key



SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) lifespan
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
--END


WITH customer_spending AS (
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(month, MIN(order_date), MAX(order_date)) lifespan
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c 
ON f.customer_key = c.customer_key
GROUP BY c.customer_key )

	SELECT
	customer_segment,
	COUNT(customer_key) AS total_customers
FROM (
SELECT 
customer_key, 
CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	 ELSE 'New'
END customer_segment
FROM customer_spending )t 
GROUP BY customer_segment
ORDER BY total_customers DESC



 


