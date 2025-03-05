## Silver Layer Table Creation Script

### Overview
This script is responsible for creating the necessary tables in the Silver layer of the data warehouse. It ensures that the tables are defined with the appropriate schema to store cleaned and standardized data from the Bronze layer.

### Table Definitions

1. **Customer Information Table (`silver.crm_cust_info`)**:
   - **Columns**:
     - `cst_id`: Customer ID (INT)
     - `cst_key`: Unique customer key (NVARCHAR(50))
     - `cst_firstname`: Customer's first name (NVARCHAR(50))
     - `cst_lastname`: Customer's last name (NVARCHAR(50))
     - `cst_marital_status`: Customer's marital status (NVARCHAR(50))
     - `cst_gndr`: Customer's gender (NVARCHAR(50))
     - `cst_create_date`: Date the customer record was created (DATE)
     - `dwh_create_date`: Timestamp of when the record was created in the data warehouse (DATETIME2, default is current date and time)

2. **Product Information Table (`silver.crm_prd_info`)**:
   - **Columns**:
     - `prd_id`: Product ID (INT)
     - `cat_id`: Category ID (NVARCHAR(50))
     - `prd_key`: Unique product key (NVARCHAR(50))
     - `prd_nm`: Product name (NVARCHAR(50))
     - `prd_cost`: Product cost (INT)
     - `prd_line`: Product line (NVARCHAR(50))
     - `prd_start_dt`: Start date of the product (DATE)
     - `prd_end_dt`: End date of the product (DATE)
     - `dwh_create_date`: Timestamp of when the record was created in the data warehouse (DATETIME2, default is current date and time)

3. **Sales Details Table (`silver.crm_sales_details`)**:
   - **Columns**:
     - `sls_ord_num`: Sales order number (NVARCHAR(50))
     - `sls_prd_key`: Product key associated with the sale (NVARCHAR(50))
     - `sls_cust_id`: Customer ID (INT)
     - `sls_order_dt`: Order date (DATE)
     - `sls_ship_dt`: Shipping date (DATE)
     - `sls_due_dt`: Due date (DATE)
     - `sls_sales`: Total sales amount (INT)
     - `sls_quantity`: Quantity sold (INT)
     - `sls_price`: Price per unit (INT)
     - `dwh_create_date`: Timestamp of when the record was created in the data warehouse (DATETIME2, default is current date and time)

4. **Customer AZ12 Table (`silver.erp_cust_az12`)**:
   - **Columns**:
     - `cid`: Customer ID (NVARCHAR(50))
     - `bdate`: Birth date (DATE)
     - `gen`: Gender (NVARCHAR(50))
     - `dwh_create_date`: Timestamp of when the record was created in the data warehouse (DATETIME2, default is current date and time)

5. **Location A101 Table (`silver.erp_loc_a101`)**:
   - **Columns**:
     - `cid`: Customer ID (NVARCHAR(50))
     - `cntry`: Country (NVARCHAR(50))
     - `dwh_create_date`: Timestamp of when the record was created in the data warehouse (DATETIME2, default is current date and time)

6. **Category G1V2 Table (`silver.erp_px_cat_g1v2`)**:
   - **Columns**:
     - `id`: Identifier (NVARCHAR(50))
     - `cat`: Category (NVARCHAR(50))
     - `subcat`: Subcategory (NVARCHAR(50))
     - `maintenance`: Maintenance information (NVARCHAR(50))
     - `dwh_create_date`: Timestamp of when the record was created in the data warehouse (DATETIME2, default is current date and time)

### Conclusion
This script is essential for setting up the Silver layer of the data warehouse, providing a structured schema for storing transformed data. It ensures that all necessary tables are created with the appropriate data types and default values for effective data management and analysis.





IF OBJECT_ID ('silver.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (

	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()

);

IF OBJECT_ID ('silver.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
	prd_id INT,
	cat_id NVARCHAR(50),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
)


IF OBJECT_ID ('silver.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()

)

IF OBJECT_ID ('silver.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()

)

IF OBJECT_ID ('silver.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
	cid NVARCHAR(50),
	cntry NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
)

IF OBJECT_ID ('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR (50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
)

