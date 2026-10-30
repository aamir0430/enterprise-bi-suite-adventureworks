USE EnterpriseBI_DW;
GO


--creating DimCreditCardType table
IF OBJECT_ID('Dim.DimCreditCardType', 'U') IS NULL
BEGIN

    SELECT
        IDENTITY(INT, 1, 1) AS CreditCardTypeKey,
        CardType AS CreditCardType

    INTO Dim.DimCreditCardType

    FROM
    (
        SELECT DISTINCT CardType
        FROM AdventureWorks2025.Sales.CreditCard
        WHERE CardType IS NOT NULL
    ) C;

END;
GO

--adding its primary key
IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id =
          OBJECT_ID('Dim.DimCreditCardType')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimCreditCardType
    ADD CONSTRAINT PK_DimCreditCardType
    PRIMARY KEY (CreditCardTypeKey);
END;
GO

--adding a unique constraint
IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id =
          OBJECT_ID('Dim.DimCreditCardType')
      AND name = 'UQ_DimCreditCardType'
)
BEGIN
    ALTER TABLE Dim.DimCreditCardType
    ADD CONSTRAINT UQ_DimCreditCardType
    UNIQUE (CreditCardType);
END;
GO