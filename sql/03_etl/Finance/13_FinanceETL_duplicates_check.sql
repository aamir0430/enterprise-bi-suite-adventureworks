USE EnterpriseBI_DW;
GO

-- Duplicate purchase orders
SELECT
    PurchaseOrderID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactPurchaseOrderHeader
GROUP BY PurchaseOrderID
HAVING COUNT(*) > 1;

-- Duplicate purchase order details
SELECT
    PurchaseOrderDetailID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactPurchaseOrders
GROUP BY PurchaseOrderDetailID
HAVING COUNT(*) > 1;

-- Duplicate currency rates
SELECT
    CurrencyRateID,
    COUNT(*) AS DuplicateCount
FROM Fact.FactCurrencyRate
GROUP BY CurrencyRateID
HAVING COUNT(*) > 1;
GO