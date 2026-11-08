
USE EnterpriseBI_DW;
GO

-- 1. Check the existing Sales dimensions and fact tables
SELECT
    SCHEMA_NAME(T.schema_id) AS SchemaName,
    T.name AS TableName,
    C.column_id AS ColumnNumber,
    C.name AS ColumnName,
    TYPE_NAME(C.user_type_id) AS DataType,
    C.max_length AS MaxLength,
    C.precision AS NumericPrecision,
    C.scale AS NumericScale,
    C.is_nullable AS IsNullable,
    C.is_identity AS IsIdentity
FROM sys.tables T
INNER JOIN sys.columns C
    ON T.object_id = C.object_id
WHERE
    (SCHEMA_NAME(T.schema_id) = 'Dim'
     AND T.name IN (
        'DimCustomer',
        'DimProduct',
        'DimSalesTerritory',
        'DimSalesPerson',
        'DimPromotion',
        'DimCurrency',
        'DimShipMethod',
        'DimAddress',
        'DimDate'
     ))
    OR
    (SCHEMA_NAME(T.schema_id) = 'Fact'
     AND T.name IN (
        'FactSales',
        'FactSalesOrderHeader'
     ))
ORDER BY
    SchemaName,
    TableName,
    ColumnNumber;
GO

-- 2. Check current warehouse row counts
SELECT 'DimCustomer' AS TableName, COUNT_BIG(*) AS TotalRows
FROM Dim.DimCustomer

UNION ALL
SELECT 'DimProduct', COUNT_BIG(*)
FROM Dim.DimProduct

UNION ALL
SELECT 'DimSalesTerritory', COUNT_BIG(*)
FROM Dim.DimSalesTerritory

UNION ALL
SELECT 'DimSalesPerson', COUNT_BIG(*)
FROM Dim.DimSalesPerson

UNION ALL
SELECT 'DimPromotion', COUNT_BIG(*)
FROM Dim.DimPromotion

UNION ALL
SELECT 'DimCurrency', COUNT_BIG(*)
FROM Dim.DimCurrency

UNION ALL
SELECT 'DimShipMethod', COUNT_BIG(*)
FROM Dim.DimShipMethod

UNION ALL
SELECT 'DimAddress', COUNT_BIG(*)
FROM Dim.DimAddress

UNION ALL
SELECT 'DimDate', COUNT_BIG(*)
FROM Dim.DimDate

UNION ALL
SELECT 'FactSales', COUNT_BIG(*)
FROM Fact.FactSales

UNION ALL
SELECT 'FactSalesOrderHeader', COUNT_BIG(*)
FROM Fact.FactSalesOrderHeader;
GO
