USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Dim.DimScrapReason', 'U') IS NULL
BEGIN
    CREATE TABLE Dim.DimScrapReason
    (
        ScrapReasonKey INT IDENTITY(1,1) NOT NULL,
        ScrapReasonID SMALLINT NOT NULL,
        ScrapReasonName NVARCHAR(50),

        -- Primary key: warehouse-generated scrap reason identifier
        CONSTRAINT PK_DimScrapReason PRIMARY KEY (ScrapReasonKey),

        -- Unique constraint: one record per source scrap reason
        CONSTRAINT UQ_DimScrapReason_ID UNIQUE (ScrapReasonID)
    );

    INSERT INTO Dim.DimScrapReason
    (
        ScrapReasonID, ScrapReasonName
    )
    SELECT
        ScrapReasonID, Name
    FROM AdventureWorks2025.Production.ScrapReason;
END;
GO