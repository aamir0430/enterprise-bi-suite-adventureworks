
USE EnterpriseBI_DW;
GO

-- Validate all dimension mappings in FactSales
SELECT
    COUNT_BIG(*) AS TotalSalesRows,
    SUM(CASE WHEN C.CustomerKey IS NULL THEN 1 ELSE 0 END)
        AS MissingCustomer,
    SUM(CASE WHEN P.ProductKey IS NULL THEN 1 ELSE 0 END)
        AS MissingProduct,
    SUM(CASE WHEN T.SalesTerritoryKey IS NULL
                  AND F.SalesTerritoryKey IS NOT NULL
             THEN 1 ELSE 0 END) AS MissingTerritory,
    SUM(CASE WHEN SP.SalesPersonKey IS NULL
                  AND F.SalesPersonKey IS NOT NULL
             THEN 1 ELSE 0 END) AS MissingSalesPerson,
    SUM(CASE WHEN PR.PromotionKey IS NULL
                  AND F.PromotionKey IS NOT NULL
             THEN 1 ELSE 0 END) AS MissingPromotion,
    SUM(CASE WHEN CU.CurrencyKey IS NULL
                  AND F.CurrencyKey IS NOT NULL
             THEN 1 ELSE 0 END) AS MissingCurrency,
    SUM(CASE WHEN SM.ShipMethodKey IS NULL
                  AND F.ShipMethodKey IS NOT NULL
             THEN 1 ELSE 0 END) AS MissingShipMethod,
    SUM(CASE WHEN BA.AddressKey IS NULL
                  AND F.BillToAddressKey IS NOT NULL
             THEN 1 ELSE 0 END) AS MissingBillAddress,
    SUM(CASE WHEN SA.AddressKey IS NULL
                  AND F.ShipToAddressKey IS NOT NULL
             THEN 1 ELSE 0 END) AS MissingShipAddress,
    SUM(CASE WHEN OD.DateKey IS NULL
                  AND F.OrderDateKey IS NOT NULL
             THEN 1 ELSE 0 END) AS MissingOrderDate,
    SUM(CASE WHEN DD.DateKey IS NULL
                  AND F.DueDateKey IS NOT NULL
             THEN 1 ELSE 0 END) AS MissingDueDate,
    SUM(CASE WHEN SD.DateKey IS NULL
                  AND F.ShipDateKey IS NOT NULL
             THEN 1 ELSE 0 END) AS MissingShipDate
FROM Fact.FactSales F
LEFT JOIN Dim.DimCustomer C
    ON F.CustomerKey = C.CustomerKey
LEFT JOIN Dim.DimProduct P
    ON F.ProductKey = P.ProductKey
LEFT JOIN Dim.DimSalesTerritory T
    ON F.SalesTerritoryKey = T.SalesTerritoryKey
LEFT JOIN Dim.DimSalesPerson SP
    ON F.SalesPersonKey = SP.SalesPersonKey
LEFT JOIN Dim.DimPromotion PR
    ON F.PromotionKey = PR.PromotionKey
LEFT JOIN Dim.DimCurrency CU
    ON F.CurrencyKey = CU.CurrencyKey
LEFT JOIN Dim.DimShipMethod SM
    ON F.ShipMethodKey = SM.ShipMethodKey
LEFT JOIN Dim.DimAddress BA
    ON F.BillToAddressKey = BA.AddressKey
LEFT JOIN Dim.DimAddress SA
    ON F.ShipToAddressKey = SA.AddressKey
LEFT JOIN Dim.DimDate OD
    ON F.OrderDateKey = OD.DateKey
LEFT JOIN Dim.DimDate DD
    ON F.DueDateKey = DD.DateKey
LEFT JOIN Dim.DimDate SD
    ON F.ShipDateKey = SD.DateKey;
GO
