## Bronze Layer Data Load Procedure

### Overview
The `load_bronze` stored procedure is designed to load data into the Bronze layer of our data warehouse. It performs the following tasks:

1. **Truncates Existing Data**: Before loading new data, the procedure truncates the existing tables in the Bronze layer to ensure that the data is fresh and up-to-date.
2. **Bulk Inserts**: It uses the `BULK INSERT` command to efficiently load data from CSV files located on the server into the corresponding tables.
3. **Performance Tracking**: The procedure tracks and prints the duration of each load operation, providing insights into the performance of the data loading process.
4. **Error Handling**: In case of any errors during execution, the procedure captures and prints error messages for troubleshooting.

### Usage
To execute the procedure, run the following command in your SQL Server environment:

```sql
EXEC bronze.load_bronze;




 --Inserting files into the created tables
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';

        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cust_info';
        BEGIN
            TRUNCATE TABLE bronze.crm_cust_info;
            PRINT '>> Inserting Data Into: bronze.crm_cust_info';
            BULK INSERT bronze.crm_cust_info 
            FROM 'C:\Users\DELL\Downloads\AA projects\dwh-datasets\source_crm\cust_info.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                TABLOCK 
            );
        END;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        BEGIN
            TRUNCATE TABLE bronze.crm_prd_info;
            PRINT '>> Inserting Data Into: bronze.crm_prd_info';
            BULK INSERT bronze.crm_prd_info 
            FROM 'C:\Users\DELL\Downloads\AA projects\dwh-datasets\source_crm\prd_info.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                TABLOCK 
            );
        END;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        BEGIN
            TRUNCATE TABLE bronze.crm_sales_details;
            PRINT '>> Inserting Data Into: bronze.crm_sales_details';
            BULK INSERT bronze.crm_sales_details 
            FROM 'C:\Users\DELL\Downloads\AA projects\dwh-datasets\source_crm\sales_details.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                TABLOCK 
            );
        END;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        BEGIN
            TRUNCATE TABLE bronze.erp_loc_a101;
            PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
            BULK INSERT bronze.erp_loc_a101 
            FROM 'C:\Users\DELL\Downloads\AA projects\dwh-datasets\source_erp\loc_a101.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                TABLOCK 
            );
        END;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        BEGIN
            TRUNCATE TABLE bronze.erp_cust_az12;
            PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
            BULK INSERT bronze.erp_cust_az12 
            FROM 'C:\Users\DELL\Downloads\AA projects\dwh-datasets\source_erp\cust_az12.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                TABLOCK 
            );
        END;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        BEGIN
            TRUNCATE TABLE bronze.erp_px_cat_g1v2;
            PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
            BULK INSERT bronze.erp_px_cat_g1v2 
            FROM 'C:\Users\DELL\Downloads\AA projects\dwh-datasets\source_erp\px_cat_g1v2.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                TABLOCK 
            );
        END;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> --------------';

        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH;
END;

