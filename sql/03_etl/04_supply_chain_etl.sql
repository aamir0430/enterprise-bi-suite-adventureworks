/*
    Enterprise Business Intelligence Suite
    Supply Chain ETL
    File: 04_supply_chain_etl.sql

    Source: AdventureWorks2025
    Target: EnterpriseBI_DW

    Shared dimensions/facts reused:
      - Dim.DimProduct
      - Dim.DimDate
      - Fact.FactPurchaseOrders (loaded by Finance ETL)

    Supply Chain-owned dimensions:
      - Dim.DimLocation
      - Dim.DimScrapReason
      - Dim.DimTransactionType

    Supply Chain facts:
      - Fact.FactInventorySnapshot
      - Fact.FactInventoryTransaction
      - Fact.FactWorkOrder

    TransactionType joins explicitly use DATABASE_DEFAULT collation
    to avoid the collation conflict previously encountered.
*/

USE [EnterpriseBI_DW];
GO

/*
  1. LOADING SUPPLY CHAIN DIMENSIONS
*/
CREATE OR ALTER PROCEDURE etl.usp_LoadSupplyChainDimensions
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* Location dimension */
        UPDATE tgt
           SET tgt.LocationName = src.Name,
               tgt.CostRate = src.CostRate,
               tgt.Availability = src.Availability
        FROM Dim.DimLocation AS tgt
        INNER JOIN AdventureWorks2025.Production.Location AS src
            ON src.LocationID = tgt.LocationID;

        INSERT INTO Dim.DimLocation
            (LocationID, LocationName, CostRate, Availability)
        SELECT
            src.LocationID,
            src.Name,
            src.CostRate,
            src.Availability
        FROM AdventureWorks2025.Production.Location AS src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Dim.DimLocation AS tgt
            WHERE tgt.LocationID = src.LocationID
        );

        /* Scrap reason dimension */
        UPDATE tgt
           SET tgt.ScrapReasonName = src.Name
        FROM Dim.DimScrapReason AS tgt
        INNER JOIN AdventureWorks2025.Production.ScrapReason AS src
            ON src.ScrapReasonID = tgt.ScrapReasonID;

        INSERT INTO Dim.DimScrapReason
            (ScrapReasonID, ScrapReasonName)
        SELECT
            src.ScrapReasonID,
            src.Name
        FROM AdventureWorks2025.Production.ScrapReason AS src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Dim.DimScrapReason AS tgt
            WHERE tgt.ScrapReasonID = src.ScrapReasonID
        );

        /* Transaction type dimension */
        UPDATE tgt
           SET tgt.TransactionTypeName =
               CASE LTRIM(RTRIM(src.TransactionType))
                   WHEN 'W' THEN 'Work Order'
                   WHEN 'S' THEN 'Sales Order'
                   WHEN 'P' THEN 'Purchase Order'
                   ELSE CONCAT('Transaction Type ', LTRIM(RTRIM(src.TransactionType)))
               END
        FROM Dim.DimTransactionType AS tgt
        INNER JOIN
        (
            SELECT DISTINCT TransactionType
            FROM AdventureWorks2025.Production.TransactionHistory
        ) AS src
            ON LTRIM(RTRIM(tgt.TransactionTypeCode)) COLLATE DATABASE_DEFAULT
             = LTRIM(RTRIM(src.TransactionType)) COLLATE DATABASE_DEFAULT;

        INSERT INTO Dim.DimTransactionType
            (TransactionTypeCode, TransactionTypeName)
        SELECT
            src.TransactionType,
            CASE LTRIM(RTRIM(src.TransactionType))
                WHEN 'W' THEN 'Work Order'
                WHEN 'S' THEN 'Sales Order'
                WHEN 'P' THEN 'Purchase Order'
                ELSE CONCAT('Transaction Type ', LTRIM(RTRIM(src.TransactionType)))
            END
        FROM
        (
            SELECT DISTINCT TransactionType
            FROM AdventureWorks2025.Production.TransactionHistory
        ) AS src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM Dim.DimTransactionType AS tgt
            WHERE LTRIM(RTRIM(tgt.TransactionTypeCode)) COLLATE DATABASE_DEFAULT
                = LTRIM(RTRIM(src.TransactionType)) COLLATE DATABASE_DEFAULT
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

/*
  2. LOADING INVENTORY SNAPSHOT
  Grain: Product + Location + Shelf + Bin for the current snapshot
*/
CREATE OR ALTER PROCEDURE etl.usp_LoadFactInventorySnapshot
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @SnapshotDateKey int;

    SELECT @SnapshotDateKey = DateKey
    FROM Dim.DimDate
    WHERE FullDate = CONVERT(date, GETDATE());

    IF @SnapshotDateKey IS NULL
    BEGIN
        ;THROW 52001, 'Current snapshot date is missing from Dim.DimDate.', 1;
    END;

    DELETE FROM Fact.FactInventorySnapshot;

    INSERT INTO Fact.FactInventorySnapshot
        (ProductKey, LocationKey, SnapshotDateKey, Shelf, Bin, Quantity)
    SELECT
        dp.ProductKey,
        dl.LocationKey,
        @SnapshotDateKey,
        pi.Shelf,
        pi.Bin,
        pi.Quantity
    FROM AdventureWorks2025.Production.ProductInventory AS pi
    INNER JOIN Dim.DimProduct AS dp
        ON dp.ProductID = pi.ProductID
    INNER JOIN Dim.DimLocation AS dl
        ON dl.LocationID = pi.LocationID;

    IF (SELECT COUNT_BIG(*) FROM Fact.FactInventorySnapshot)
       <> (SELECT COUNT_BIG(*) FROM AdventureWorks2025.Production.ProductInventory)
    BEGIN
        ;THROW 52002, 'FactInventorySnapshot row count differs from Production.ProductInventory. Check product and location mappings.', 1;
    END;
END;
GO

/*
  3. LOADING INVENTORY TRANSACTIONS
  Grain: one row per Production.TransactionHistory record
*/
CREATE OR ALTER PROCEDURE etl.usp_LoadFactInventoryTransaction
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DELETE FROM Fact.FactInventoryTransaction;

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
        th.TransactionID,
        dp.ProductKey,
        dtt.TransactionTypeKey,
        dd.DateKey,
        th.ReferenceOrderID,
        th.ReferenceOrderLineID,
        th.Quantity,
        th.ActualCost
    FROM AdventureWorks2025.Production.TransactionHistory AS th
    INNER JOIN Dim.DimProduct AS dp
        ON dp.ProductID = th.ProductID
    INNER JOIN Dim.DimTransactionType AS dtt
        ON LTRIM(RTRIM(dtt.TransactionTypeCode)) COLLATE DATABASE_DEFAULT
         = LTRIM(RTRIM(th.TransactionType)) COLLATE DATABASE_DEFAULT
    INNER JOIN Dim.DimDate AS dd
        ON dd.FullDate = CONVERT(date, th.TransactionDate);

    IF (SELECT COUNT_BIG(*) FROM Fact.FactInventoryTransaction)
       <> (SELECT COUNT_BIG(*) FROM AdventureWorks2025.Production.TransactionHistory)
    BEGIN
        ;THROW 52003, 'FactInventoryTransaction row count differs from Production.TransactionHistory. Check product, transaction type, and date mappings.', 1;
    END;
END;
GO

/*
  4. LOADING WORK ORDERS
  Grain: one row per Production.WorkOrder record
*/
CREATE OR ALTER PROCEDURE etl.usp_LoadFactWorkOrder
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DELETE FROM Fact.FactWorkOrder;

    INSERT INTO Fact.FactWorkOrder
    (
        WorkOrderID,
        ProductKey,
        ScrapReasonKey,
        StartDateKey,
        EndDateKey,
        DueDateKey,
        OrderQty,
        StockedQty,
        ScrappedQty,
        ProductionDurationDays
    )
    SELECT
        wo.WorkOrderID,
        dp.ProductKey,
        sr.ScrapReasonKey,
        startDate.DateKey,
        endDate.DateKey,
        dueDate.DateKey,
        wo.OrderQty,
        wo.StockedQty,
        wo.ScrappedQty,
        CASE
            WHEN wo.EndDate IS NULL THEN NULL
            ELSE DATEDIFF(DAY, CONVERT(date, wo.StartDate), CONVERT(date, wo.EndDate))
        END
    FROM AdventureWorks2025.Production.WorkOrder AS wo
    INNER JOIN Dim.DimProduct AS dp
        ON dp.ProductID = wo.ProductID
    LEFT JOIN Dim.DimScrapReason AS sr
        ON sr.ScrapReasonID = wo.ScrapReasonID
    INNER JOIN Dim.DimDate AS startDate
        ON startDate.FullDate = CONVERT(date, wo.StartDate)
    LEFT JOIN Dim.DimDate AS endDate
        ON endDate.FullDate = CONVERT(date, wo.EndDate)
    INNER JOIN Dim.DimDate AS dueDate
        ON dueDate.FullDate = CONVERT(date, wo.DueDate);

    IF (SELECT COUNT_BIG(*) FROM Fact.FactWorkOrder)
       <> (SELECT COUNT_BIG(*) FROM AdventureWorks2025.Production.WorkOrder)
    BEGIN
        ;THROW 52004, 'FactWorkOrder row count differs from Production.WorkOrder. Check product and date mappings.', 1;
    END;
END;
GO

/*
  5. MASTER SUPPLY CHAIN ETL
*/
CREATE OR ALTER PROCEDURE etl.usp_RunSupplyChainETL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC etl.usp_LoadSupplyChainDimensions;
        EXEC etl.usp_LoadFactInventorySnapshot;
        EXEC etl.usp_LoadFactInventoryTransaction;
        EXEC etl.usp_LoadFactWorkOrder;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

/*
  6. VERIFY STORED PROCEDURE CREATION
*/
SELECT
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS ProcedureName
FROM sys.procedures
WHERE schema_id = SCHEMA_ID('etl')
  AND name IN
  (
      'usp_LoadSupplyChainDimensions',
      'usp_LoadFactInventorySnapshot',
      'usp_LoadFactInventoryTransaction',
      'usp_LoadFactWorkOrder',
      'usp_RunSupplyChainETL'
  )
ORDER BY name;
GO