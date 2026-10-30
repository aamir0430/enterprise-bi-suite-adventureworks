USE EnterpriseBI_DW;
GO

DROP TABLE IF EXISTS Dim.DimAddress;
GO

SELECT
    IDENTITY(INT, 1, 1) AS AddressKey,

    CAST(A.AddressID AS INT) AS AddressID,

    A.AddressLine1,
    A.AddressLine2,
    A.City,
    A.PostalCode,

    SP.StateProvinceID,
    SP.Name AS StateProvinceName,
    SP.StateProvinceCode,

    CR.CountryRegionCode,
    CR.Name AS CountryName,

    SP.TerritoryID

INTO Dim.DimAddress

FROM AdventureWorks2025.Person.Address A

LEFT JOIN AdventureWorks2025.Person.StateProvince SP
    ON A.StateProvinceID = SP.StateProvinceID

LEFT JOIN AdventureWorks2025.Person.CountryRegion CR
    ON SP.CountryRegionCode = CR.CountryRegionCode;
GO