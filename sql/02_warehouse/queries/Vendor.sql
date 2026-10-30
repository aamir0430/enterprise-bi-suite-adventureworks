USE EnterpriseBI_DW
GO

IF OBJECT_ID('AdventureWorks2025.Purchasing.Vendor','U') IS NOT NULL
	PRINT 'Source Vendor table exists.';
ELSE
	PRINT 'ERROR: Source Vendor table was not found.';
GO

SELECT
	COUNT(*) AS TotalVendors,
	COUNT(DISTINCT BusinessEntityID) AS DistinctVendorIDs
FROM AdventureWorks2025.Purchasing.Vendor;
GO

SELECT
	BusinessEntityID,
	COUNT(*) AS DuplicateCount
FROM AdventureWorks2025.Purchasing.Vendor
GROUP BY BusinessEntityID
HAVING COUNT(*)>1;
GO

SELECT
    SUM(CASE WHEN BusinessEntityID IS NULL THEN 1 ELSE 0 END)
        AS NullVendorIDs,
    SUM(CASE WHEN AccountNumber IS NULL OR LTRIM(RTRIM(AccountNumber)) = ''
             THEN 1 ELSE 0 END) AS MissingAccountNumbers,
    SUM(CASE WHEN Name IS NULL OR LTRIM(RTRIM(Name)) = ''
             THEN 1 ELSE 0 END) AS MissingVendorNames,
    SUM(CASE WHEN CreditRating IS NULL THEN 1 ELSE 0 END)
        AS NullCreditRatings,
    SUM(CASE WHEN ModifiedDate IS NULL THEN 1 ELSE 0 END)
        AS NullModifiedDates
FROM AdventureWorks2025.Purchasing.Vendor;
GO

SELECT
    CreditRating,
    COUNT(*) AS VendorCount
FROM AdventureWorks2025.Purchasing.Vendor
GROUP BY CreditRating
ORDER BY CreditRating;
GO

SELECT
    PreferredVendorStatus,
    ActiveFlag,
    COUNT(*) AS VendorCount
FROM AdventureWorks2025.Purchasing.Vendor
GROUP BY PreferredVendorStatus, ActiveFlag
ORDER BY PreferredVendorStatus, ActiveFlag;
GO

