USE EnterpriseBI_DW;
GO

SELECT
    IDENTITY(INT, 1, 1) AS CustomerKey,

    C.CustomerID,
    C.PersonID,
    C.StoreID,
    C.TerritoryID,
    C.AccountNumber,

    P.PersonType,
    P.Title,
    P.FirstName,
    P.MiddleName,
    P.LastName,
    P.Suffix,

    S.Name AS StoreName,

    CASE
        WHEN C.PersonID IS NOT NULL THEN
            CONCAT(
                P.FirstName, ' ',
                COALESCE(P.MiddleName + ' ', ''),
                P.LastName
            )
        WHEN C.StoreID IS NOT NULL THEN S.Name
        ELSE 'Unknown Customer'
    END AS CustomerName

INTO Dim.DimCustomer

FROM AdventureWorks2025.Sales.Customer C

LEFT JOIN AdventureWorks2025.Person.Person P
    ON C.PersonID = P.BusinessEntityID

LEFT JOIN AdventureWorks2025.Sales.Store S
    ON C.StoreID = S.BusinessEntityID;
GO