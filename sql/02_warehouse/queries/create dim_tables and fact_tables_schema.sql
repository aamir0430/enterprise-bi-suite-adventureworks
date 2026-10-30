--Create Dim and Fact schema to store the dimension tables and fact tables

USE EnterpriseBI_DW;
GO

IF SCHEMA_ID('Dim') IS NULL
    EXEC('CREATE SCHEMA Dim');

IF SCHEMA_ID('Fact') IS NULL
    EXEC('CREATE SCHEMA Fact');
GO

-- Check that both schemas exist
SELECT name AS SchemaName
FROM sys.schemas
WHERE name IN (N'dim_tables', N'fact_tables');