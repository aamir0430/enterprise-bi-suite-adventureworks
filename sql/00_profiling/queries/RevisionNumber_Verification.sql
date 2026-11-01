USE EnterpriseBI_DW
GO

SELECT
	RevisionNumber,
	COUNT(*) AS OrderCount
FROM AdventureWorks2025.Sales.SalesOrderHeader
GROUP BY RevisionNumber
ORDER BY RevisionNumber;

SELECT
	RevisionNumber,
	COUNT(*) AS OrderCount
FROM Fact.FactSalesOrderHeader
GROUP BY RevisionNumber
ORDER BY RevisionNumber;