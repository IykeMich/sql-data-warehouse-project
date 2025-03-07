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


CREATE VIEW gold.report_products AS
WITH base_query AS (
/*
	1. Retrieves core columns from fact_sales and dim_products
*/
	SELECT 
		f.order_number,
		f.order_date,
		f.customer_key,
		f.sales_amount,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON f.product_key = p.product_key
	WHERE order_date IS NOT NULL --only consider valid sales dates
),

product_aggregations AS (
/*
2) Product Aggregations:  Summarizes key metrics at the product level
*/
SELECT product_key, 
	   product_name, 
	   category, 
	   subcategory, 
	   cost,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sale_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query

GROUP BY
	product_key,
	product_name,
	category,
	subcategory,
	cost
)
SELECT
/*
	3. Final Query: Combines all prouct results into one output
*/
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 50000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	--Average Order Revenue (AOR)
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,

	-- Average Monthly Revenue
	CASE WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue
FROM product_aggregations


SELECT * FROM gold.report_products
