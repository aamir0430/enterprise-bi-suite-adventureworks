USE EnterpriseBI_DW
GO

SELECT
    IDENTITY(INT, 1, 1) AS SalesPersonKey,

    SP.BusinessEntityID AS SalesPersonID,

    P.FirstName,
    P.MiddleName,
    P.LastName,

    CONCAT(
        P.FirstName, ' ',
        COALESCE(P.MiddleName + ' ', ''),
        P.LastName
    ) AS SalesPersonName,

    E.JobTitle,

    SP.TerritoryID,
    SP.SalesQuota,
    SP.Bonus,
    SP.CommissionPct,
    SP.SalesYTD,
    SP.SalesLastYear

INTO Dim.DimSalesPerson

FROM AdventureWorks2025.Sales.SalesPerson SP

INNER JOIN AdventureWorks2025.HumanResources.Employee E
    ON SP.BusinessEntityID = E.BusinessEntityID

INNER JOIN AdventureWorks2025.Person.Person P
    ON E.BusinessEntityID = P.BusinessEntityID;
GO