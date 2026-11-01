USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Dim.DimTransactionType', 'U') IS NULL
BEGIN
    CREATE TABLE Dim.DimTransactionType
    (
        TransactionTypeKey INT IDENTITY(1,1) NOT NULL,
        TransactionTypeCode NCHAR(1) NOT NULL,
        TransactionTypeName NVARCHAR(30) NOT NULL,

        -- Primary key: warehouse-generated transaction type identifier
        CONSTRAINT PK_DimTransactionType
            PRIMARY KEY (TransactionTypeKey),

        -- Unique constraint: each source transaction type appears once
        CONSTRAINT UQ_DimTransactionType_Code
            UNIQUE (TransactionTypeCode)
    );

    INSERT INTO Dim.DimTransactionType
    (
        TransactionTypeCode, TransactionTypeName
    )
    SELECT DISTINCT
        TransactionType,
        CASE TransactionType
            WHEN 'W' THEN 'Work Order'
            WHEN 'S' THEN 'Sales Order'
            WHEN 'P' THEN 'Purchase Order'
            ELSE 'Other'
        END
    FROM AdventureWorks2025.Production.TransactionHistory;
END;
GO