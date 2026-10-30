USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Fact.FactCurrencyRate', 'U') IS NULL
BEGIN

    SELECT
        IDENTITY(BIGINT, 1, 1) AS CurrencyRateFactKey,

        CR.CurrencyRateID,

        -- Date dimension
        CONVERT(
            INT,
            CONVERT(CHAR(8), CR.CurrencyRateDate, 112)
        ) AS CurrencyRateDateKey,

        -- Currency dimensions
        FC.CurrencyKey AS FromCurrencyKey,
        TC.CurrencyKey AS ToCurrencyKey,

        -- Exchange rate measures
        CR.AverageRate,
        CR.EndOfDayRate,

        CR.CurrencyRateDate

    INTO Fact.FactCurrencyRate

    FROM AdventureWorks2025.Sales.CurrencyRate CR

    LEFT JOIN Dim.DimCurrency FC
        ON CR.FromCurrencyCode = FC.CurrencyCode

    LEFT JOIN Dim.DimCurrency TC
        ON CR.ToCurrencyCode = TC.CurrencyCode;

END;
GO

--Add primary key
IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id =
          OBJECT_ID('Fact.FactCurrencyRate')
      AND type = 'PK'
)
BEGIN

    ALTER TABLE Fact.FactCurrencyRate
    ADD CONSTRAINT PK_FactCurrencyRate
    PRIMARY KEY (CurrencyRateFactKey);

END;
GO

--Add unique constraint
IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id =
          OBJECT_ID('Fact.FactCurrencyRate')
      AND name = 'UQ_FactCurrencyRate_CurrencyRateID'
)
BEGIN

    ALTER TABLE Fact.FactCurrencyRate
    ADD CONSTRAINT UQ_FactCurrencyRate_CurrencyRateID
    UNIQUE (CurrencyRateID);

END;
GO

--Add foreign keys
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_FactCurrencyRate_Date'
)
ALTER TABLE Fact.FactCurrencyRate
ADD CONSTRAINT FK_FactCurrencyRate_Date
FOREIGN KEY (CurrencyRateDateKey)
REFERENCES Dim.DimDate(DateKey);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_FactCurrencyRate_FromCurrency'
)
ALTER TABLE Fact.FactCurrencyRate
ADD CONSTRAINT FK_FactCurrencyRate_FromCurrency
FOREIGN KEY (FromCurrencyKey)
REFERENCES Dim.DimCurrency(CurrencyKey);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_FactCurrencyRate_ToCurrency'
)
ALTER TABLE Fact.FactCurrencyRate
ADD CONSTRAINT FK_FactCurrencyRate_ToCurrency
FOREIGN KEY (ToCurrencyKey)
REFERENCES Dim.DimCurrency(CurrencyKey);
GO
