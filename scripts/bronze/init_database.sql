/* ================================================
   Script Purpose:
   This script is designed to drop and recreate the 
   'DataWareHouse1' database in SQL Server. It also 
   creates three schemas: 'bronze', 'silver', and 
   'gold' within the newly created database. 
   This is useful for setting up a fresh environment 
   for data warehousing purposes.
   ================================================ */

/* ================================================
   WARNING:
   This script will permanently delete the 'DataWareHouse1' 
   database and all its contents. Ensure that you have 
   backed up any important data before running this script. 
   This action cannot be undone.
   ================================================ */

USE master;
GO

-- Drop and recreate the 'DataWareHouse1' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWareHouse1')
BEGIN
    ALTER DATABASE DataWareHouse1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWareHouse1;
END;
GO

-- Create the "DataWareHouse1" database
CREATE DATABASE DataWareHouse1;
GO

USE DataWareHouse1;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
