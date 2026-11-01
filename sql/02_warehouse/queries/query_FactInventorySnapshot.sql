USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Fact.FactInventorySnapshot', 'U') IS NULL
BEGIN
    CREATE TABLE Fact.FactInventorySnapshot
    (
        InventorySnapshotKey BIGINT IDENTITY(1,1) NOT NULL,
        ProductKey INT NOT NULL,
        LocationKey INT NOT NULL,
        SnapshotDateKey INT NOT NULL,
        Shelf NCHAR(10) NOT NULL,
        Bin TINYINT NOT NULL,
        Quantity SMALLINT NOT NULL,

        -- Primary key: uniquely identifies each snapshot record
        CONSTRAINT PK_FactInventorySnapshot
            PRIMARY KEY (InventorySnapshotKey),

        -- Unique constraint: prevents duplicate product/shelf/bin
        -- records for the same location and snapshot date
        CONSTRAINT UQ_FactInventorySnapshot
            UNIQUE
            (ProductKey, LocationKey, SnapshotDateKey, Shelf, Bin),

        -- Foreign keys: connect to the shared product dimension
        CONSTRAINT FK_InventorySnapshot_Product
            FOREIGN KEY (ProductKey)
            REFERENCES Dim.DimProduct(ProductKey),

        -- Foreign key: connects to the new location dimension
        CONSTRAINT FK_InventorySnapshot_Location
            FOREIGN KEY (LocationKey)
            REFERENCES Dim.DimLocation(LocationKey),

        -- Foreign key: connects snapshot date to the date dimension
        CONSTRAINT FK_InventorySnapshot_Date
            FOREIGN KEY (SnapshotDateKey)
            REFERENCES Dim.DimDate(DateKey)
    );

    INSERT INTO Fact.FactInventorySnapshot
    (
        ProductKey, LocationKey, SnapshotDateKey,
        Shelf, Bin, Quantity
    )
    SELECT
        DP.ProductKey,
        DL.LocationKey,
        CONVERT(INT, CONVERT(CHAR(8), GETDATE(), 112)),
        PI.Shelf,
        PI.Bin,
        PI.Quantity

    FROM AdventureWorks2025.Production.ProductInventory PI

    INNER JOIN Dim.DimProduct DP
        ON PI.ProductID = DP.ProductID

    INNER JOIN Dim.DimLocation DL
        ON PI.LocationID = DL.LocationID;
END;
GO