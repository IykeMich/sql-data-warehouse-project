## Data Quality Checks and Validation Queries

### Overview
This section contains a series of SQL queries designed to perform quality checks and data validation on various tables within the Bronze and Silver layers of the data warehouse. The purpose of these queries is to ensure data integrity, identify potential issues, and standardize data formats across different datasets.

### Quality Checks

1. **Customer Information (silver.crm_cust_info)**:
   - **Duplicate Check**: Identifies duplicate customer IDs and checks for NULL values.
   - **Whitespace Check**: Detects unwanted leading or trailing spaces in customer last names.
   - **Data Normalization**: Lists distinct gender values to ensure consistency.

2. **Product Information (bronze.crm_prd_info)**:
   - **Invalid Date Orders**: Checks for records where the end date is earlier than the start date.

3. **Sales Details (bronze.crm_sales_details)**:
   - **Sales Validation**: Validates sales data by checking for discrepancies between sales, quantity, and price.
   - **Error Correction**: Provides a corrected view of sales and price data based on defined business rules.

4. **Customer Data (bronze.erp_cust_az12)**:
   - **Customer ID Check**: Filters records based on specific customer ID patterns.
   - **Date of Birth Validation**: Ensures that birth dates are within a valid range.
   - **Gender Standardization**: Normalizes gender values to 'Male', 'Female', or 'n/a'.

5. **Location Data (bronze.erp_loc_a101)**:
   - **Country Standardization**: Replaces country codes with full names and handles NULL or empty values.

6. **Category Data (bronze.erp_px_cat_g1v2)**:
   - **Data Structure Check**: Ensures that the data is well-structured and free of errors.

### Conclusion
The queries in this section are essential for maintaining high data quality standards within the data warehouse. They help identify and rectify issues, ensuring that the data is reliable for analysis and reporting purposes. Regular execution of these checks is recommended to uphold data integrity.





/* CODE */

--for crm_cust_info
--quality check
--SELECT cst_id, COUNT(*) FROM silver.crm_cust_info
--GROUP BY cst_id
--HAVING COUNT(*) > 1 OR cst_id IS NULL


--check for unwanted spaces
--SELECT cst_lastname
--FROM silver.crm_cust_info
--WHERE cst_lastname != TRIM(cst_lastname)

--data normalization and standardization
--SELECT DISTINCT cst_gndr
--FROM silver.crm_cust_info


--FOR CST_PRD_INFO

--cHECK FOR INVALID DATE ORDERS
--SELECT * FROM bronze.crm_prd_info WHERE
--prd_end_dt < prd_start_dt

--CHECK THE CRM SALES FOR ERRORS
--SELECT DISTINCT 

--sls_sales, sls_quantity, sls_price FROM bronze.crm_sales_details
--WHERE sls_sales != sls_quantity * sls_price
--OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
--OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
--ORDER BY sls_sales, sls_quantity, sls_price


--SELECT DISTINCT 

--sls_sales AS old_sls_price, 
--sls_quantity, 
--sls_price AS old_sls_price,

--CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
--	THEN sls_quantity * ABS(sls_price)
--	ELSE sls_sales
--END AS sls_sales,

--CASE WHEN sls_price IS NULL OR sls_price <= 0
--	THEN sls_sales / NULLIF(sls_quantity, 0)
--	ELSE sls_price
--END AS sls_price

--FROM bronze.crm_sales_details
--WHERE sls_sales != sls_quantity * sls_price
--OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
--OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
--ORDER BY sls_sales, sls_quantity, sls_price


--FOR ERP CUST AZ12
--SELECT
--*
--FROM bronze.erp_cust_az12
--WHERE cid LIKE 'NAS%'

--SELECT DISTINCT bdate 
--FROM bronze.erp_cust_az12
--WHERE bdate < '1900-01-01' OR bdate > GETDATE()

--select * FROM bronze.erp_cust_az12

--select DISTINCT gen FROM bronze.erp_cust_az12

--select 
--SUBSTRING(cid, 4, LEN(cid)) AS cid,
--CASE WHEN bdate > GETDATE() THEN NULL
--	ELSE bdate
--END AS bdate,
--CASE UPPER(TRIM(gen))
--	WHEN 'F' THEN 'Female'
--	WHEN 'M' THEN 'Male'
--	ELSE 'n/a'
--END AS gen
--FROM bronze.erp_cust_az12


--FOR ERP LOC A101
--select DISTINCT cntry from bronze.erp_loc_a101

--select 
--REPLACE (cid, '-', '_') AS cid,
--CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
--	 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
--	 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
--	 ELSE TRIM(cntry)
--END AS cntry
--FROM bronze.erp_loc_a101


SELECT * FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2
SELECT cat FROM bronze.erp_px_cat_g1v2 WHERE TRIM(cat) != cat
SELECT DISTINCT maintenance from bronze.erp_px_cat_g1v2

/* THE DATA IS WELL STRUCTURED AND HAS NO ERRORS */
