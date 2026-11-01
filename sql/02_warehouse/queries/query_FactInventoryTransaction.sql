USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Fact.FactInventoryTransaction', 'U') IS NULL
BEGIN
    CREATE TABLE Fact.FactInventoryTransaction
    (
        InventoryTransactionKey BIGINT IDENTITY(1,1) NOT NULL,
        TransactionID INT NOT NULL,
        ProductKey INT NOT NULL,
        TransactionTypeKey INT NOT NULL,
        TransactionDateKey INT NOT NULL,
        ReferenceOrderID INT NULL,
        ReferenceOrderLineID INT NULL,
        Quantity INT NOT NULL,
        ActualCost MONEY NOT NULL,

        -- Primary Key: uniquely identifies each transaction
        CONSTRAINT PK_FactInventoryTransaction
            PRIMARY KEY (InventoryTransactionKey),

        -- Unique Constraint: prevents duplicate source transactions
        CONSTRAINT UQ_FactInventoryTransaction_ID
            UNIQUE (TransactionID),

        -- Foreign Key: connects to DimProduct
        CONSTRAINT FK_InventoryTransaction_Product
            FOREIGN KEY (ProductKey)
            REFERENCES Dim.DimProduct(ProductKey),

        -- Foreign Key: connects to DimTransactionType
        CONSTRAINT FK_InventoryTransaction_Type
            FOREIGN KEY (TransactionTypeKey)
            REFERENCES Dim.DimTransactionType(TransactionTypeKey),

        -- Foreign Key: connects to DimDate
        CONSTRAINT FK_InventoryTransaction_Date
            FOREIGN KEY (TransactionDateKey)
            REFERENCES Dim.DimDate(DateKey)
    );

    -- Insert inventory transaction records
    INSERT INTO Fact.FactInventoryTransaction
    (
        TransactionID,
        ProductKey,
        TransactionTypeKey,
        TransactionDateKey,
        ReferenceOrderID,
        ReferenceOrderLineID,
        Quantity,
        ActualCost
    )
    SELECT
        TH.TransactionID,
        DP.ProductKey,
        DTT.TransactionTypeKey,
        CONVERT(INT, CONVERT(CHAR(8), TH.TransactionDate, 112)),
        TH.ReferenceOrderID,
        TH.ReferenceOrderLineID,
        TH.Quantity,
        TH.ActualCost

    FROM AdventureWorks2025.Production.TransactionHistory TH

    INNER JOIN Dim.DimProduct DP
        ON TH.ProductID = DP.ProductID

    INNER JOIN Dim.DimTransactionType DTT
        ON TH.TransactionType COLLATE DATABASE_DEFAULT
           = DTT.TransactionTypeCode COLLATE DATABASE_DEFAULT;

END;
GO