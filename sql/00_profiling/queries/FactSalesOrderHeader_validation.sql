USE EnterpriseBI_DW
GO

-- Validating the primary keys and order identifiers:

-- 1. Validating the row count and keys
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT SalesOrderHeaderKey) AS DistinctHeaderKeys,
    COUNT(DISTINCT SalesOrderID) AS DistinctSalesOrderIDs,
    COUNT(DISTINCT SalesOrderNumber) AS DistinctOrderNumbers,
    SUM(CASE WHEN SalesOrderHeaderKey IS NULL THEN 1 ELSE 0 END)
        AS NullHeaderKeys,
    SUM(CASE WHEN SalesOrderID IS NULL THEN 1 ELSE 0 END)
        AS NullSalesOrderIDs
FROM Fact.FactSalesOrderHeader;

-- 2. Checking duplicate sales orders
SELECT
    SalesOrderID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactSalesOrderHeader
GROUP BY SalesOrderID
HAVING COUNT(*) > 1;

-- 3. Checking duplicate order numbers
SELECT
    SalesOrderNumber,
    COUNT(*) AS DuplicateCount
FROM Fact.FactSalesOrderHeader
GROUP BY SalesOrderNumber
HAVING COUNT(*) > 1;

-- Validating missing salesperson and currency information

-- 1. Missing salesperson by online/offline order
SELECT
    OnlineOrderFlag,
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN SalesPersonKey IS NULL
             THEN 1 ELSE 0 END) AS MissingSalesPerson,
    SUM(CASE WHEN SalesPersonKey IS NOT NULL
             THEN 1 ELSE 0 END) AS AssignedSalesPerson
FROM Fact.FactSalesOrderHeader
GROUP BY OnlineOrderFlag;

-- 2. Missing Currency information
SELECT
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN CurrencyRateID IS NULL
             THEN 1 ELSE 0 END) AS MissingCurrencyRate,
    SUM(CASE WHEN FromCurrencyCode IS NULL
             THEN 1 ELSE 0 END) AS MissingFromCurrency,
    SUM(CASE WHEN FromCurrencyCode IS NULL
             THEN 1 ELSE 0 END) AS MissingCurrencyCode,
    SUM(CASE WHEN AverageRate IS NULL
             THEN 1 ELSE 0 END) AS MissingAverageRate,
    SUM(CASE WHEN EndOfDayRate IS NULL
             THEN 1 ELSE 0 END) AS MissingEndOfDayRate
FROM Fact.FactSalesOrderHeader;

-- Validating Foreign keys:

-- 1. Customer
SELECT F.CustomerKey
FROM Fact.FactSalesOrderHeader F
LEFT JOIN Dim.DimCustomer D
    ON F.CustomerKey = D.CustomerKey
WHERE D.CustomerKey IS NULL;

-- 2. Sales territory
SELECT F.SalesTerritoryKey
FROM Fact.FactSalesOrderHeader F
LEFT JOIN Dim.DimSalesTerritory D
    ON F.SalesTerritoryKey = D.SalesTerritoryKey
WHERE D.SalesTerritoryKey IS NULL;

-- 3. SalesPerson
SELECT F.SalesPersonKey
FROM Fact.FactSalesOrderHeader F
LEFT JOIN Dim.DimSalesPerson D
    ON F.SalesPersonKey = D.SalesPersonKey
WHERE F.SalesPersonKey IS NOT NULL
  AND D.SalesPersonKey IS NULL;

-- 4. ShipMethod
SELECT F.ShipMethodKey
FROM Fact.FactSalesOrderHeader F
LEFT JOIN Dim.DimShipMethod D
    ON F.ShipMethodKey = D.ShipMethodKey
WHERE D.ShipMethodKey IS NULL;

-- 5. Bill-to address
SELECT F.BillToAddressKey
FROM Fact.FactSalesOrderHeader F
LEFT JOIN Dim.DimAddress D
    ON F.BillToAddressKey = D.AddressKey
WHERE D.AddressKey IS NULL;

-- 6. Ship-to address
SELECT F.ShipToAddressKey
FROM Fact.FactSalesOrderHeader F
LEFT JOIN Dim.DimAddress D
    ON F.ShipToAddressKey = D.AddressKey
WHERE D.AddressKey IS NULL;

-- 7. CreditCardType
SELECT F.CreditCardTypeKey
FROM Fact.FactSalesOrderHeader F
LEFT JOIN Dim.DimCreditCardType D
    ON F.CreditCardTypeKey = D.CreditCardTypeKey
WHERE F.CreditCardTypeKey IS NOT NULL
  AND D.CreditCardTypeKey IS NULL;

-- 8. Order, due and ship dates
SELECT F.OrderDateKey
FROM Fact.FactSalesOrderHeader F
LEFT JOIN Dim.DimDate D
    ON F.OrderDateKey = D.DateKey
WHERE D.DateKey IS NULL;

SELECT F.DueDateKey
FROM Fact.FactSalesOrderHeader F
LEFT JOIN Dim.DimDate D
    ON F.DueDateKey = D.DateKey
WHERE D.DateKey IS NULL;

SELECT F.ShipDateKey
FROM Fact.FactSalesOrderHeader F
LEFT JOIN Dim.DimDate D
    ON F.ShipDateKey = D.DateKey
WHERE D.DateKey IS NULL;

-- Validating financial measures:

-- 1. Checking negative financial values
SELECT *
FROM Fact.FactSalesOrderHeader
WHERE Subtotal < 0
   OR TaxAmt < 0
   OR Freight < 0
   OR TotalDue < 0;

-- 2. Validating TotalDue
SELECT
    SalesOrderID,
    Subtotal,
    TaxAmt,
    Freight,
    TotalDue,
    ROUND(Subtotal + TaxAmt + Freight, 2) AS ExpectedTotalDue
FROM Fact.FactSalesOrderHeader
WHERE ABS(
    TotalDue - ROUND(Subtotal + TaxAmt + Freight, 2)
) > 0.01;

-- Validating dates and order status:

-- 1. Checking date sequence
SELECT *
FROM Fact.FactSalesOrderHeader
WHERE DueDateKey < OrderDateKey
   OR ShipDateKey < OrderDateKey;

-- 2. Reviewing order statuses
SELECT
    Status,
    COUNT(*) AS OrderCount
FROM Fact.FactSalesOrderHeader
GROUP BY Status
ORDER BY Status;

-- 3. Reviewing revision numbers
SELECT
    RevisionNumber,
    COUNT(*) AS OrderCount
FROM Fact.FactSalesOrderHeader
GROUP BY RevisionNumber
ORDER BY RevisionNumber;

-- Validating currency rate relationships:

SELECT F.CurrencyRateID
FROM Fact.FactSalesOrderHeader F
LEFT JOIN Fact.FactCurrencyRate C
    ON F.CurrencyRateID = C.CurrencyRateID
WHERE F.CurrencyRateID IS NOT NULL
  AND C.CurrencyRateID IS NULL;