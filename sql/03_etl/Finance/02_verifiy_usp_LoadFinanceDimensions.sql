USE EnterpriseBI_DW;
GO

-- 1. Verifying the dimension row counts

SELECT 'DimVendor' AS TableName, COUNT_BIG(*) AS TotalRows
FROM Dim.DimVendor

UNION ALL

SELECT 'DimEmployee', COUNT_BIG(*)
FROM Dim.DimEmployee

UNION ALL

SELECT 'DimProduct', COUNT_BIG(*)
FROM Dim.DimProduct

UNION ALL

SELECT 'DimShipMethod', COUNT_BIG(*)
FROM Dim.DimShipMethod

UNION ALL

SELECT 'DimCurrency', COUNT_BIG(*)
FROM Dim.DimCurrency;
GO