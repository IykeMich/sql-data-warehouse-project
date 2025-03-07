/*
===========================================================================================
CUSTOMER REPORT
===========================================================================================
Purpose:
		This report consolidates key customer metrics and behaviors

Highlights:
		1. Gathers essential fields such as names, ages, and transaction details.
		2. Segments customers into categories (VIP, Regular, New) and Age groups
		3. Aggregatess customer-level metrics:
			- total orders
			- total sales
			- total quantity purchased
			- total products
			- lifespan (in months)
		4. Calculates Valuable KPIs:
			- recency (months since last order)
			- average order value
			- average monthly spend
============================================================================================
*/


/*
		1. Gathers essential fields such as names, ages, and transaction details.
*/
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
c.first_name,
c.last_name,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
c.birthdate
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key





/*
		3. Aggregatess customer-level metrics:
			- total orders
			- total sales
			- total quantity purchased
			- total products
			- lifespan (in months)
*/

CREATe VIEW gold.report_customers AS
WITH base_query AS (
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
DATEDIFF (year, c.birthdate, GETDATE()) age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL )

, customer_aggregation AS (
/*
		2. Segments customers into categories (VIP, Regular, New) and Age groups
*/
SELECT customer_key, customer_number, customer_name, age,
	COUNT(DISTINCT order_number) AS total_orders, 
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY
		customer_key,
		customer_number,
		customer_name,
		age
)
SELECT 
		customer_key,
		customer_number,
		customer_name,
		age,
		CASE WHEN age < 20 THEN 'Under 20'
			 WHEN age between 20 and 29 THEN '20-29'
			 WHEN age between 30 and 39 THEN '30-39'
			 WHEN age between 40 and 49 THEN '40-49'
			ELSE '50 and above'
		END age_group,
		CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
			ELSE 'New'
		END customer_segment,
		last_order_date,
		DATEDIFF(month, last_order_date, GETDATE()) AS recency,
		total_orders, 
		total_sales,
		total_quantity,
		total_products
		lifespan,
		--compute avg order value (AVO)
		CASE WHEN total_sales = 0 THEN 0
			ELSE total_sales / total_orders 
		END AS avg_order_value,

		--compute avg monthly spend
		CASE WHEN lifespan = 0 THEN total_sales
			ELSE total_sales / lifespan
		END avg_monthly_spend
		FROM customer_aggregation


--simple EDAs
		 
SELECT * FROM gold.report_customers

SELECT customer_segment, 
COUnT(customer_number) AS total_customers,
SUM(total_sales) total_sales
FROM gold.report_customers
GROUP BY customer_segment
