USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Dim.DimLocation', 'U') IS NULL
BEGIN
    CREATE TABLE Dim.DimLocation
    (
        LocationKey INT IDENTITY(1,1) NOT NULL,
        LocationID SMALLINT NOT NULL,
        LocationName NVARCHAR(50),
        CostRate SMALLMONEY,
        Availability DECIMAL(8,2),

        -- Primary key: warehouse-generated location identifier
        CONSTRAINT PK_DimLocation PRIMARY KEY (LocationKey),

        -- Unique constraint: one warehouse record per source location
        CONSTRAINT UQ_DimLocation_LocationID UNIQUE (LocationID)
    );

    INSERT INTO Dim.DimLocation
    (
        LocationID, LocationName, CostRate, Availability
    )
    SELECT
        LocationID, Name, CostRate, Availability
    FROM AdventureWorks2025.Production.Location;
END;
GO