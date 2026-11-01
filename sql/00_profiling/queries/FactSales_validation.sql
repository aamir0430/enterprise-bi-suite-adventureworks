USE EnterpriseBI_DW
GO

-- Validating primary keys and sales order identifiers:

-- 1. Validating row count and unique keys
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT SalesFactKey) AS DistinctSalesFactKeys,
    COUNT(DISTINCT SalesOrderDetailID) AS DistinctOrderDetailIDs,
    SUM(CASE WHEN SalesFactKey IS NULL THEN 1 ELSE 0 END)
        AS NullSalesFactKeys,
    SUM(CASE WHEN SalesOrderDetailID IS NULL THEN 1 ELSE 0 END)
        AS NullOrderDetailIDs
FROM Fact.FactSales;

-- 2. Checking duplicate sales order detail IDs
SELECT
    SalesOrderDetailID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactSales
GROUP BY SalesOrderDetailID
HAVING COUNT(*) > 1;

-- 3. Checking sales order line distribution
SELECT
    SalesOrderID,
    SalesOrderNumber,
    COUNT(*) AS NumberOfOrderLines
FROM Fact.FactSales
GROUP BY SalesOrderID, SalesOrderNumber
ORDER BY NumberOfOrderLines DESC;

-- Validating foreign keys and dimension relationships:

-- 1. Checking for Customer
SELECT F.CustomerKey
FROM Fact.FactSales F
LEFT JOIN Dim.DimCustomer D
    ON F.CustomerKey = D.CustomerKey
WHERE D.CustomerKey IS NULL;

-- 2. Checking for Product
SELECT F.ProductKey
FROM Fact.FactSales F
LEFT JOIN Dim.DimProduct D
    ON F.ProductKey = D.ProductKey
WHERE D.ProductKey IS NULL;

-- 3. Checking for Sales territory
SELECT F.SalesTerritoryKey
FROM Fact.FactSales F
LEFT JOIN Dim.DimSalesTerritory D
    ON F.SalesTerritoryKey = D.SalesTerritoryKey
WHERE D.SalesTerritoryKey IS NULL;

-- 4. Checking for Salesperson
SELECT F.SalesPersonKey
FROM Fact.FactSales F
LEFT JOIN Dim.DimSalesPerson D
    ON F.SalesPersonKey = D.SalesPersonKey
WHERE F.SalesPersonKey IS NOT NULL
  AND D.SalesPersonKey IS NULL;

-- 5. Checking for Promotion
SELECT F.PromotionKey
FROM Fact.FactSales F
LEFT JOIN Dim.DimPromotion D
    ON F.PromotionKey = D.PromotionKey
WHERE D.PromotionKey IS NULL;

-- 6. Checking for Currency
SELECT F.CurrencyKey
FROM Fact.FactSales F
LEFT JOIN Dim.DimCurrency D
    ON F.CurrencyKey = D.CurrencyKey
WHERE F.CurrencyKey IS NOT NULL
  AND D.CurrencyKey IS NULL;

-- 7. Checking for Ship method
SELECT F.ShipMethodKey
FROM Fact.FactSales F
LEFT JOIN Dim.DimShipMethod D
    ON F.ShipMethodKey = D.ShipMethodKey
WHERE D.ShipMethodKey IS NULL;

-- 8. Checking for bill-to and ship-to addresses
SELECT F.BillToAddressKey
FROM Fact.FactSales F
LEFT JOIN Dim.DimAddress D
    ON F.BillToAddressKey = D.AddressKey
WHERE D.AddressKey IS NULL;

SELECT F.ShipToAddressKey
FROM Fact.FactSales F
LEFT JOIN Dim.DimAddress D
    ON F.ShipToAddressKey = D.AddressKey
WHERE D.AddressKey IS NULL;

-- 9. Checking for Order, due and ship dates
SELECT F.OrderDateKey
FROM Fact.FactSales F
LEFT JOIN Dim.DimDate D
    ON F.OrderDateKey = D.DateKey
WHERE D.DateKey IS NULL;

SELECT F.DueDateKey
FROM Fact.FactSales F
LEFT JOIN Dim.DimDate D
    ON F.DueDateKey = D.DateKey
WHERE D.DateKey IS NULL;

SELECT F.ShipDateKey
FROM Fact.FactSales F
LEFT JOIN Dim.DimDate D
    ON F.ShipDateKey = D.DateKey
WHERE D.DateKey IS NULL;

-- Validating sales quantities, prices and totals:

-- 1. Checking order quantities
SELECT *
FROM Fact.FactSales
WHERE OrderQty <= 0;

-- 2. Checking unit prices and discounts
SELECT *
FROM Fact.FactSales
WHERE UnitPrice < 0
   OR UnitPriceDiscount < 0
   OR UnitPriceDiscount > 1;

-- 3. Validating LineTotal
SELECT
    SalesOrderDetailID,
    OrderQty,
    UnitPrice,
    UnitPriceDiscount,
    LineTotal,
    ROUND(
        OrderQty * UnitPrice * (1 - UnitPriceDiscount),
        2
    ) AS ExpectedLineTotal
FROM Fact.FactSales
WHERE ABS(
    LineTotal -
    ROUND(
        OrderQty * UnitPrice * (1 - UnitPriceDiscount),
        2
    )
) > 0.01;

-- Validating the three date columns:

SELECT *
FROM Fact.FactSales
WHERE DueDateKey < OrderDateKey
   OR ShipDateKey < OrderDateKey;