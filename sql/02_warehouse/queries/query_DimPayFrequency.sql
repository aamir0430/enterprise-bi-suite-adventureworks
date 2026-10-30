USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Dim.DimPayFrequency', 'U') IS NULL
BEGIN
    CREATE TABLE Dim.DimPayFrequency
    (
        PayFrequencyKey INT IDENTITY(1,1) NOT NULL,
        PayFrequencyCode TINYINT NOT NULL,
        PayFrequencyName VARCHAR(30) NOT NULL,

        CONSTRAINT PK_DimPayFrequency
            PRIMARY KEY (PayFrequencyKey),

        CONSTRAINT UQ_DimPayFrequency_Code
            UNIQUE (PayFrequencyCode)
    );

    INSERT INTO Dim.DimPayFrequency
    (
        PayFrequencyCode,
        PayFrequencyName
    )
    VALUES
        (1, 'Monthly'),
        (2, 'Biweekly');
END;
GO