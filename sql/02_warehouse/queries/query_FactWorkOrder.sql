USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Fact.FactWorkOrder', 'U') IS NULL
BEGIN
    CREATE TABLE Fact.FactWorkOrder
    (
        WorkOrderFactKey BIGINT IDENTITY(1,1) NOT NULL,
        WorkOrderID INT NOT NULL,
        ProductKey INT NOT NULL,
        ScrapReasonKey INT NULL,
        StartDateKey INT NOT NULL,
        EndDateKey INT NULL,
        DueDateKey INT NOT NULL,
        OrderQty INT NOT NULL,
        StockedQty INT NOT NULL,
        ScrappedQty SMALLINT NOT NULL,
        ProductionDurationDays INT,

        -- Primary key: warehouse-generated work order identifier
        CONSTRAINT PK_FactWorkOrder
            PRIMARY KEY (WorkOrderFactKey),

        -- Unique constraint: one warehouse record per source work order
        CONSTRAINT UQ_FactWorkOrder_ID
            UNIQUE (WorkOrderID),

        -- Foreign key: connects to product dimension
        CONSTRAINT FK_WorkOrder_Product
            FOREIGN KEY (ProductKey)
            REFERENCES Dim.DimProduct(ProductKey),

        -- Foreign key: connects to scrap reason dimension
        CONSTRAINT FK_WorkOrder_ScrapReason
            FOREIGN KEY (ScrapReasonKey)
            REFERENCES Dim.DimScrapReason(ScrapReasonKey),

        -- Foreign keys: connect all work order dates to DimDate
        CONSTRAINT FK_WorkOrder_StartDate
            FOREIGN KEY (StartDateKey)
            REFERENCES Dim.DimDate(DateKey),

        CONSTRAINT FK_WorkOrder_EndDate
            FOREIGN KEY (EndDateKey)
            REFERENCES Dim.DimDate(DateKey),

        CONSTRAINT FK_WorkOrder_DueDate
            FOREIGN KEY (DueDateKey)
            REFERENCES Dim.DimDate(DateKey)
    );

    INSERT INTO Fact.FactWorkOrder
    (
        WorkOrderID, ProductKey, ScrapReasonKey,
        StartDateKey, EndDateKey, DueDateKey,
        OrderQty, StockedQty, ScrappedQty,
        ProductionDurationDays
    )
    SELECT
        W.WorkOrderID,
        DP.ProductKey,
        DSR.ScrapReasonKey,

        CONVERT(INT, CONVERT(CHAR(8), W.StartDate, 112)),

        CASE
            WHEN W.EndDate IS NOT NULL
            THEN CONVERT(INT, CONVERT(CHAR(8), W.EndDate, 112))
            ELSE NULL
        END,

        CONVERT(INT, CONVERT(CHAR(8), W.DueDate, 112)),

        W.OrderQty,
        W.StockedQty,
        W.ScrappedQty,

        CASE
            WHEN W.EndDate IS NOT NULL
            THEN DATEDIFF(DAY, W.StartDate, W.EndDate)
            ELSE NULL
        END

    FROM AdventureWorks2025.Production.WorkOrder W

    INNER JOIN Dim.DimProduct DP
        ON W.ProductID = DP.ProductID

    LEFT JOIN Dim.DimScrapReason DSR
        ON W.ScrapReasonID = DSR.ScrapReasonID;
END;
GO