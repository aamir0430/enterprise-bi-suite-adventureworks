USE EnterpriseBI_DW;
GO

-- 1. Verifying FactPurchaseOrderHeader row counts

SELECT
    COUNT_BIG(*) AS TotalRows,
    COUNT(DISTINCT PurchaseOrderID) AS DistinctOrders
FROM Fact.FactPurchaseOrderHeader;
GO

-- 2. Checking missing dimension mappings

SELECT COUNT_BIG(*) AS MissingMappings
FROM Fact.FactPurchaseOrderHeader
WHERE VendorKey IS NULL
   OR EmployeeKey IS NULL
   OR ShipMethodKey IS NULL
   OR OrderDateKey IS NULL;
GO