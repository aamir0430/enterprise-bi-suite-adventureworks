USE EnterpriseBI_DW
GO

-- 1. Verifying the FactPurchaseOrders table row counts

SELECT
    COUNT_BIG(*) AS TotalRows,
    COUNT(DISTINCT PurchaseOrderDetailID) AS DistinctOrderDetails
FROM Fact.FactPurchaseOrders;
GO

-- 2. Checking missing mappings

SELECT COUNT_BIG(*) AS MissingMappings
FROM Fact.FactPurchaseOrders
WHERE VendorKey IS NULL
   OR ProductKey IS NULL
   OR EmployeeKey IS NULL
   OR ShipMethodKey IS NULL
   OR OrderDateKey IS NULL
   OR DueDateKey IS NULL;
GO