USE EnterpriseBI_DW
GO

SELECT
    IDENTITY(INT, 1, 1) AS CurrencyKey,

    CurrencyCode,
    Name AS CurrencyName

INTO Dim.DimCurrency

FROM AdventureWorks2025.Sales.Currency;
GO