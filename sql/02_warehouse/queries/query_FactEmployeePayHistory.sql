USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Fact.FactEmployeePayHistory', 'U') IS NULL
BEGIN

    CREATE TABLE Fact.FactEmployeePayHistory
    (
        PayHistoryFactKey BIGINT IDENTITY(1,1) NOT NULL,
        EmployeeKey INT NOT NULL,
        PayFrequencyKey INT NOT NULL,
        RateChangeDateKey INT NOT NULL,
        Rate MONEY NOT NULL,

        -- Primary Key: uniquely identifies each pay-history record
        CONSTRAINT PK_FactEmployeePayHistory
            PRIMARY KEY (PayHistoryFactKey),

        -- Unique Constraint: prevents duplicate employee pay changes
        CONSTRAINT UQ_EmployeePayHistory
            UNIQUE (EmployeeKey, RateChangeDateKey),

        -- Foreign Keys: connect to employee and pay-frequency dimensions
        CONSTRAINT FK_PayHistory_Employee
            FOREIGN KEY (EmployeeKey)
            REFERENCES Dim.DimEmployee(EmployeeKey),

        CONSTRAINT FK_PayHistory_Frequency
            FOREIGN KEY (PayFrequencyKey)
            REFERENCES Dim.DimPayFrequency(PayFrequencyKey),

        -- Foreign Key: connects the rate change date to DimDate
        CONSTRAINT FK_PayHistory_Date
            FOREIGN KEY (RateChangeDateKey)
            REFERENCES Dim.DimDate(DateKey)
    );

    -- Insert employee pay-history records
    INSERT INTO Fact.FactEmployeePayHistory
    (
        EmployeeKey, PayFrequencyKey,
        RateChangeDateKey, Rate
    )
    SELECT
        DE.EmployeeKey,
        DPF.PayFrequencyKey,
        CONVERT(INT, CONVERT(CHAR(8), PH.RateChangeDate, 112)),
        PH.Rate

    FROM AdventureWorks2025.HumanResources.EmployeePayHistory PH

    INNER JOIN Dim.DimEmployee DE
        ON PH.BusinessEntityID = DE.EmployeeID

    INNER JOIN Dim.DimPayFrequency DPF
        ON PH.PayFrequency = DPF.PayFrequencyCode;

END;
GO