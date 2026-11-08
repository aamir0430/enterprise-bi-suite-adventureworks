USE EnterpriseBI_DW;
GO

SELECT 'DimCustomer' AS TableName, COUNT_BIG(*) AS TotalRows
FROM Dim.DimCustomer

UNION ALL
SELECT 'DimProduct', COUNT_BIG(*) FROM Dim.DimProduct

UNION ALL
SELECT 'DimSalesTerritory', COUNT_BIG(*) FROM Dim.DimSalesTerritory

UNION ALL
SELECT 'DimSalesPerson', COUNT_BIG(*) FROM Dim.DimSalesPerson

UNION ALL
SELECT 'DimPromotion', COUNT_BIG(*) FROM Dim.DimPromotion

UNION ALL
SELECT 'DimCurrency', COUNT_BIG(*) FROM Dim.DimCurrency

UNION ALL
SELECT 'DimShipMethod', COUNT_BIG(*) FROM Dim.DimShipMethod

UNION ALL
SELECT 'DimAddress', COUNT_BIG(*) FROM Dim.DimAddress;
GO