## Gold Layer Views Creation Script

### Overview
This script is responsible for creating several views in the Gold layer of the data warehouse. These views are designed to provide a consolidated and structured representation of customer, product, and sales data, facilitating easier analysis and reporting.

### Key Components

1. **Customer View (`gold.dim_customers`)**:
   - This view consolidates customer information from the `silver.crm_cust_info`, `silver.erp_cust_az12`, and `silver.erp_loc_a101` tables.
   - It includes fields such as customer ID, customer number, first and last names, country, marital status, gender, birthdate, and creation date.
   - A row number is generated for each customer, serving as a unique key (`customer_key`).
   - The view also includes a check for duplicate customer entries, ensuring data integrity.

2. **Product View (`gold.dim_products`)**:
   - This view aggregates product information from the `silver.crm_prd_info` and `silver.erp_px_cat_g1v2` tables.
   - It includes fields such as product ID, product number, product name, category, subcategory, maintenance information, cost, product line, and start date.
   - A row number is generated for each product, serving as a unique key (`product_key`).
   - The view filters out historical data by excluding products with an end date.

3. **Sales Fact View (`gold.fact_sales`)**:
   - This view combines sales details from the `silver.crm_sales_details` table with the previously created customer and product views.
   - It includes fields such as order number, product key, customer key, order date, shipping date, due date, sales amount, sales quantity, and price.
   - This view serves as the central fact table for sales analysis.

### Data Integrity Checks
- The script includes checks for duplicate entries in both the customer and product views to ensure that the data is unique and reliable.
- A final check is performed to verify that the sales view can successfully connect to both the customer and product views without any duplicates.

### Conclusion
The views created by this script are essential for providing a structured and reliable dataset for analysis in the Gold layer of the data warehouse. They facilitate efficient querying and reporting, ensuring that stakeholders have access to accurate and meaningful insights.






/* Customer View  */
CREATE VIEW gold.dim_customers AS
SELECT
ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_marital_status AS marital_status,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	ELSE COALESCE(ca.gen, 'n/a')
END AS gender,
ca.bdate AS birthdate,
ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

/* SELECT * FROM silver.crm_cust_info */
/* SELECT * FROM silver.erp_cust_az12*/
/* SELECT * FROM silver.erp_loc_a101 */


/* Crosschecking for duplicate values. EXPECTATION: find none. RESULT:found None */
SELECT customer_key, COUNT(*) FROM (
SELECT
ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_marital_status AS marital_status,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	ELSE COALESCE(ca.gen, 'n/a')
END AS gender,
ca.bdate AS birthdate,
ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
)t GROUP BY customer_key
HAVING COUNT (*) > 1


/* product view */
CREATE VIEW gold.dim_products AS
SELECT
ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key,
pn.prd_id AS product_id, 
pn.prd_key AS product_number, 
pn.prd_nm AS product_name, 
pn.cat_id AS category_id, 
pc.cat AS category,
pc.subcat AS subcategory,
pc.maintenance,
pn.prd_cost AS cost, 
pn.prd_line AS product_line,
pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL --Filter out all historical data 

SELECT * FROM gold.dim_customers



/* CHECKING FOR DUPLICATE */
SELECT prd_key, COUNT(*) FROM (
SELECT
pn.prd_id, pn.cat_id, pn.prd_key, pn.prd_nm, pn.prd_cost, pn.prd_line,
pn.prd_start_dt
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL --Filter out all historical data 
)t GROUP BY prd_key
HAVING COUNT(*) > 1


--CREATE GOLD SALES VIEW
CREATE VIEW gold.fact_sales AS
SELECT
sd.sls_ord_num AS order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS sales_quantity,
sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id


--Overall Checking to See if we can connect the entire views
--EXPECTAION: NO DUPLICATES
--RESULT: NO DUPLICATES

SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL
