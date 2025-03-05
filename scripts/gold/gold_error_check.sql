## Gender Data Cleaning and Sorting Script

### Overview
This script is designed to clean and standardize gender data from the customer information and customer AZ12 tables in the Silver layer of the data warehouse. It aims to provide a clearer representation of gender values for analysis and reporting.

### Key Operations

1. **Gender Standardization**:
   - The script selects distinct gender values from the `silver.crm_cust_info` and `silver.erp_cust_az12` tables.
   - It uses a `CASE` statement to create a new column (`new_gender`) that standardizes the gender representation:
     - If the gender in `silver.crm_cust_info` is not 'n/a', it retains that value.
     - If the gender is 'n/a', it attempts to use the gender value from the `silver.erp_cust_az12` table, defaulting to 'n/a' if no valid value is found.

2. **Data Retrieval**:
   - The script retrieves distinct gender values along with their corresponding entries from both tables, ensuring that the output is clean and free of duplicates.
   - The results are ordered by the original gender values and the new standardized gender values for better readability.

3. **Additional Data Inspection**:
   - The script includes two additional `SELECT` statements to retrieve all records from the `silver.crm_cust_info` and `silver.erp_cust_az12` tables. This allows for a comprehensive view of the data before and after the cleaning process.

### Conclusion
This script is essential for ensuring that gender data is consistently represented across the customer datasets. By standardizing gender values, it enhances the quality of the data for subsequent analysis and reporting, making it easier to derive insights related to customer demographics.




/* Sorting the gender to make it cleaner */
SELECT DISTINCT ci.cst_gndr, ca.gen, 
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	ELSE COALESCE(ca.gen, 'n/a')
END AS new_gender
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
ORDER BY 1, 2




SELECT * FROM silver.crm_cust_info
SELECT * FROM silver.erp_cust_az12
