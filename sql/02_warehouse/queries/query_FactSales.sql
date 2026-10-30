USE EnterpriseBI_DW;
GO

SELECT
    IDENTITY(BIGINT, 1, 1) AS SalesFactKey,

    -- Transaction identifiers
    H.SalesOrderID,
    D.SalesOrderDetailID,
    H.SalesOrderNumber,

    -- Sales information
    H.OnlineOrderFlag,

    -- Dimension keys
    DC.CustomerKey,
    DP.ProductKey,
    DST.SalesTerritoryKey,
    DSP.SalesPersonKey,
    DPR.PromotionKey,
    DCUR.CurrencyKey,
    DSM.ShipMethodKey,

    DBA.AddressKey AS BillToAddressKey,
    DSA.AddressKey AS ShipToAddressKey,

    -- Date keys
    CONVERT(INT, CONVERT(CHAR(8), H.OrderDate, 112))
        AS OrderDateKey,

    CONVERT(INT, CONVERT(CHAR(8), H.DueDate, 112))
        AS DueDateKey,

    CASE
        WHEN H.ShipDate IS NOT NULL
        THEN CONVERT(INT, CONVERT(CHAR(8), H.ShipDate, 112))
        ELSE NULL
    END AS ShipDateKey,

    -- Source currency conversion reference
    H.CurrencyRateID,

    -- Sales measures
    D.OrderQty,
    D.UnitPrice,
    D.UnitPriceDiscount,
    D.LineTotal

INTO Fact.FactSales

FROM AdventureWorks2025.Sales.SalesOrderHeader H

INNER JOIN AdventureWorks2025.Sales.SalesOrderDetail D
    ON H.SalesOrderID = D.SalesOrderID

LEFT JOIN Dim.DimCustomer DC
    ON H.CustomerID = DC.CustomerID

LEFT JOIN Dim.DimProduct DP
    ON D.ProductID = DP.ProductID

LEFT JOIN Dim.DimSalesTerritory DST
    ON H.TerritoryID = DST.TerritoryID

LEFT JOIN Dim.DimSalesPerson DSP
    ON H.SalesPersonID = DSP.SalesPersonID

LEFT JOIN Dim.DimPromotion DPR
    ON D.SpecialOfferID = DPR.SpecialOfferID

LEFT JOIN AdventureWorks2025.Sales.CurrencyRate CR
    ON H.CurrencyRateID = CR.CurrencyRateID

LEFT JOIN Dim.DimCurrency DCUR
    ON CR.ToCurrencyCode = DCUR.CurrencyCode

LEFT JOIN Dim.DimShipMethod DSM
    ON H.ShipMethodID = DSM.ShipMethodID

LEFT JOIN Dim.DimAddress DBA
    ON H.BillToAddressID = DBA.AddressID

LEFT JOIN Dim.DimAddress DSA
    ON H.ShipToAddressID = DSA.AddressID;
GO