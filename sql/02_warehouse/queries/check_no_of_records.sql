USE EnterpriseBI_DW
GO


--Checking the no. of records for FactSales
SELECT 'DimCustomer' AS TableName, COUNT(*) AS TotalRows
FROM Dim.DimCustomer

UNION ALL

SELECT 'DimProduct', COUNT(*)
FROM Dim.DimProduct

UNION ALL

SELECT 'DimDate', COUNT(*)
FROM Dim.DimDate

UNION ALL

SELECT 'DimSalesTerritory', COUNT(*)
FROM Dim.DimSalesTerritory

UNION ALL

SELECT 'DimSalesPerson', COUNT(*)
FROM Dim.DimSalesPerson

UNION ALL

SELECT 'DimPromotion', COUNT(*)
FROM Dim.DimPromotion

UNION ALL

SELECT 'DimCurrency', COUNT(*)
FROM Dim.DimCurrency

UNION ALL

SELECT 'DimShipMethod', COUNT(*)
FROM Dim.DimShipMethod

UNION ALL

SELECT 'DimAddress', COUNT(*)
FROM Dim.DimAddress;


--Checking total records for FactSalesOrderHeader
SELECT
    COUNT(*) AS TotalOrders,
    COUNT(DISTINCT SalesOrderID) AS UniqueOrders,
    SUM(SubTotal) AS TotalSubTotal,
    SUM(TaxAmt) AS TotalTax,
    SUM(Freight) AS TotalFreight,
    SUM(TotalDue) AS TotalAmountDue
FROM Fact.FactSalesOrderHeader;