USE EnterpriseBI_DW;
GO

-- Prevent accidental recreation of an existing table
IF OBJECT_ID('Fact.FactSalesOrderHeader', 'U') IS NOT NULL
BEGIN
    THROW 50001,
    'FactSalesOrderHeader already exists. Do not recreate it.',
    1;
END;
GO

SELECT
    IDENTITY(BIGINT, 1, 1) AS SalesOrderHeaderKey,

    -- Original transaction identifiers
    H.SalesOrderID,
    H.SalesOrderNumber,
    H.PurchaseOrderNumber,
    H.AccountNumber,

    -- Dimension keys
    DC.CustomerKey,
    DST.SalesTerritoryKey,
    DSP.SalesPersonKey,
    DSM.ShipMethodKey,

    DBA.AddressKey AS BillToAddressKey,
    DSA.AddressKey AS ShipToAddressKey,

    -- Date dimension keys
    CONVERT(
        INT,
        CONVERT(CHAR(8), H.OrderDate, 112)
    ) AS OrderDateKey,

    CONVERT(
        INT,
        CONVERT(CHAR(8), H.DueDate, 112)
    ) AS DueDateKey,

    CASE
        WHEN H.ShipDate IS NOT NULL
        THEN CONVERT(
            INT,
            CONVERT(CHAR(8), H.ShipDate, 112)
        )
        ELSE NULL
    END AS ShipDateKey,

    -- Order attributes
    H.RevisionNumber,
    H.Status,
    H.OnlineOrderFlag,

    -- Currency information
    H.CurrencyRateID,
    CR.FromCurrencyCode,
    CR.ToCurrencyCode,
    CR.AverageRate,
    CR.EndOfDayRate,

    -- Order-level financial measures
    H.SubTotal,
    H.TaxAmt,
    H.Freight,
    H.TotalDue,

    -- Additional information
    H.Comment,
    H.ModifiedDate

INTO Fact.FactSalesOrderHeader

FROM AdventureWorks2025.Sales.SalesOrderHeader H

LEFT JOIN Dim.DimCustomer DC
    ON H.CustomerID = DC.CustomerID

LEFT JOIN Dim.DimSalesTerritory DST
    ON H.TerritoryID = DST.TerritoryID

LEFT JOIN Dim.DimSalesPerson DSP
    ON H.SalesPersonID = DSP.SalesPersonID

LEFT JOIN Dim.DimShipMethod DSM
    ON H.ShipMethodID = DSM.ShipMethodID

LEFT JOIN Dim.DimAddress DBA
    ON H.BillToAddressID = DBA.AddressID

LEFT JOIN Dim.DimAddress DSA
    ON H.ShipToAddressID = DSA.AddressID

LEFT JOIN AdventureWorks2025.Sales.CurrencyRate CR
    ON H.CurrencyRateID = CR.CurrencyRateID;
GO