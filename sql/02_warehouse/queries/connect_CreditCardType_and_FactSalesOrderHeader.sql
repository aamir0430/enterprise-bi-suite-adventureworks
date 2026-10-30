USE EnterpriseBI_DW;
GO

IF COL_LENGTH(
    'Fact.FactSalesOrderHeader',
    'CreditCardTypeKey'
) IS NULL
BEGIN

    ALTER TABLE Fact.FactSalesOrderHeader
    ADD CreditCardTypeKey INT NULL;

END;
GO

--populating it with original source
UPDATE F
SET F.CreditCardTypeKey = DCC.CreditCardTypeKey

FROM Fact.FactSalesOrderHeader F

INNER JOIN AdventureWorks2025.Sales.SalesOrderHeader H
    ON F.SalesOrderID = H.SalesOrderID

LEFT JOIN AdventureWorks2025.Sales.CreditCard CC
    ON H.CreditCardID = CC.CreditCardID

LEFT JOIN Dim.DimCreditCardType DCC
    ON CC.CardType = DCC.CreditCardType;
GO

--adding the foreign key
IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_FactSalesOrderHeader_CreditCardType'
)
BEGIN

    ALTER TABLE Fact.FactSalesOrderHeader
    ADD CONSTRAINT FK_FactSalesOrderHeader_CreditCardType
    FOREIGN KEY (CreditCardTypeKey)
    REFERENCES Dim.DimCreditCardType(CreditCardTypeKey);

END;
GO