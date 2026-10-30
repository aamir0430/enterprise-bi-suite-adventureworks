USE EnterpriseBI_DW;
GO

--Checking Finance Dimension row counts

SELECT 'DimCurrency' AS TableName, COUNT(*) AS TotalRows
FROM Dim.DimCurrency

UNION ALL

SELECT 'DimVendor', COUNT(*)
FROM Dim.DimVendor

UNION ALL

SELECT 'DimProduct', COUNT(*)
FROM Dim.DimProduct

UNION ALL

SELECT 'DimEmployee', COUNT(*)
FROM Dim.DimEmployee

UNION ALL

SELECT 'DimDate', COUNT(*)
FROM Dim.DimDate

UNION ALL

SELECT 'DimCreditCardType', COUNT(*)
FROM Dim.DimCreditCardType;

--Checking Finance fact row counts
SELECT 'FactSalesOrderHeader' AS TableName, COUNT(*) AS TotalRows
FROM Fact.FactSalesOrderHeader

UNION ALL

SELECT 'FactPurchaseOrderHeader', COUNT(*)
FROM Fact.FactPurchaseOrderHeader

UNION ALL

SELECT 'FactPurchaseOrders', COUNT(*)
FROM Fact.FactPurchaseOrders

UNION ALL

SELECT 'FactCurrencyRate', COUNT(*)
FROM Fact.FactCurrencyRate;

--Comparing source and warehouse purchase order counts
SELECT
    (
        SELECT COUNT(*)
        FROM AdventureWorks2025.Purchasing.PurchaseOrderHeader
    ) AS SourcePurchaseOrders,

    (
        SELECT COUNT(*)
        FROM Fact.FactPurchaseOrderHeader
    ) AS WarehousePurchaseOrders;

--Comparing purchase order line counts
SELECT
    (
        SELECT COUNT(*)
        FROM AdventureWorks2025.Purchasing.PurchaseOrderDetail
    ) AS SourcePurchaseOrderLines,

    (
        SELECT COUNT(*)
        FROM Fact.FactPurchaseOrders
    ) AS WarehousePurchaseOrderLines;

--Checking purchasing financial totals
SELECT
    COUNT(*) AS TotalPurchaseOrders,
    SUM(SubTotal) AS TotalPurchaseSubTotal,
    SUM(TaxAmt) AS TotalPurchaseTax,
    SUM(Freight) AS TotalPurchaseFreight,
    SUM(TotalDue) AS TotalPurchaseDue
FROM Fact.FactPurchaseOrderHeader;

--Checking currency-rate records
SELECT
    COUNT(*) AS TotalCurrencyRates,

    COUNT(DISTINCT CurrencyRateID)
        AS UniqueCurrencyRates,

    COUNT(FromCurrencyKey)
        AS MatchedFromCurrencies,

    COUNT(ToCurrencyKey)
        AS MatchedToCurrencies,

    MIN(AverageRate) AS MinimumAverageRate,
    MAX(AverageRate) AS MaximumAverageRate

FROM Fact.FactCurrencyRate;

--Checking duplicate purchase order lines
SELECT
    PurchaseOrderDetailID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactPurchaseOrders
GROUP BY PurchaseOrderDetailID
HAVING COUNT(*) > 1;

--Checking missing dimension mappings - Investigating any missing values against the source records.
SELECT
    SUM(CASE WHEN VendorKey IS NULL THEN 1 ELSE 0 END)
        AS MissingVendor,

    SUM(CASE WHEN EmployeeKey IS NULL THEN 1 ELSE 0 END)
        AS MissingEmployee,

    SUM(CASE WHEN ShipMethodKey IS NULL THEN 1 ELSE 0 END)
        AS MissingShipMethod

FROM Fact.FactPurchaseOrderHeader;