USE EnterpriseBI_DW
GO

-- Validating vendor keys and duplicates:

-- 1. Validating row count and keys
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT VendorKey) AS DistinctVendorKeys,
    COUNT(DISTINCT VendorID) AS DistinctVendorIDs,
    SUM(CASE WHEN VendorKey IS NULL THEN 1 ELSE 0 END)
        AS NullVendorKeys,
    SUM(CASE WHEN VendorID IS NULL THEN 1 ELSE 0 END)
        AS NullVendorIDs
FROM Dim.DimVendor;

-- 2. Checking duplicate vendor IDs
SELECT
    VendorID,
    COUNT(*) AS DuplicateCount
FROM Dim.DimVendor
GROUP BY VendorID
HAVING COUNT(*) > 1;

-- 3. Checking duplicate account numbers
SELECT
    AccountNumber,
    COUNT(*) AS DuplicateCount
FROM Dim.DimVendor
GROUP BY AccountNumber
HAVING COUNT(*) > 1;

-- 4. Checking duplicate vendor names
SELECT
    VendorName,
    COUNT(*) AS DuplicateCount
FROM Dim.DimVendor
GROUP BY VendorName
HAVING COUNT(*) > 1;

-- Validating credit ratings and vendor flags:

SELECT
    CreditRating,
    COUNT(*) AS VendorCount
FROM Dim.DimVendor
GROUP BY CreditRating
ORDER BY CreditRating;

-- Checking for invalid ratings
SELECT *
FROM Dim.DimVendor
WHERE CreditRating NOT BETWEEN 1 AND 5;

-- Reviewing the vendor flags
SELECT
    PreferredVendorStatus,
    ActiveFlag,
    COUNT(*) AS VendorCount
FROM Dim.DimVendor
GROUP BY PreferredVendorStatus, ActiveFlag
ORDER BY PreferredVendorStatus, ActiveFlag;

-- Validating purchasing URLs:

-- 1. Checking whether populated URLs are blank or malformed
SELECT *
FROM Dim.DimVendor
WHERE PurchasingWebServiceURL IS NOT NULL
  AND LTRIM(RTRIM(PurchasingWebServiceURL)) = '';

-- 2. Inspecting the populated URLs
SELECT
    VendorID,
    VendorName,
    PurchasingWebServiceURL
FROM Dim.DimVendor
WHERE PurchasingWebServiceURL IS NOT NULL;

-- Validating source modified dates:

SELECT
    MIN(SourceModifiedDate) AS EarliestModifiedDate,
    MAX(SourceModifiedDate) AS LatestModifiedDate,
    COUNT(DISTINCT SourceModifiedDate) AS DistinctModifiedDates
FROM Dim.DimVendor;