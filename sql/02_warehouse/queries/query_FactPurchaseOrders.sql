USE EnterpriseBI_DW;
GO

IF OBJECT_ID('Fact.FactPurchaseOrders', 'U') IS NULL
BEGIN

    SELECT
        IDENTITY(BIGINT, 1, 1) AS PurchaseFactKey,

        -- Source identifiers
        H.PurchaseOrderID,
        D.PurchaseOrderDetailID,

        -- Dimension keys
        DV.VendorKey,
        DP.ProductKey,
        DE.EmployeeKey,
        DSM.ShipMethodKey,

        -- Date keys
        CONVERT(
            INT,
            CONVERT(CHAR(8), H.OrderDate, 112)
        ) AS OrderDateKey,

        CONVERT(
            INT,
            CONVERT(CHAR(8), D.DueDate, 112)
        ) AS DueDateKey,

        -- Order attributes
        H.Status,

        -- Purchase measures
        D.OrderQty,
        D.ReceivedQty,
        D.RejectedQty,
        D.StockedQty,
        D.UnitPrice,
        D.LineTotal,

        D.OrderQty * D.UnitPrice AS OrderedAmount

    INTO Fact.FactPurchaseOrders

    FROM AdventureWorks2025.Purchasing.PurchaseOrderHeader H

    INNER JOIN AdventureWorks2025.Purchasing.PurchaseOrderDetail D
        ON H.PurchaseOrderID = D.PurchaseOrderID

    LEFT JOIN Dim.DimVendor DV
        ON H.VendorID = DV.VendorID

    LEFT JOIN Dim.DimProduct DP
        ON D.ProductID = DP.ProductID

    LEFT JOIN Dim.DimEmployee DE
        ON H.EmployeeID = DE.EmployeeID

    LEFT JOIN Dim.DimShipMethod DSM
        ON H.ShipMethodID = DSM.ShipMethodID;

END;
GO

--Add primary keys
IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id =
          OBJECT_ID('Fact.FactPurchaseOrders')
      AND type = 'PK'
)
BEGIN

    ALTER TABLE Fact.FactPurchaseOrders
    ADD CONSTRAINT PK_FactPurchaseOrders
    PRIMARY KEY (PurchaseFactKey);

END;
GO

--Add unique constraints
IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id =
          OBJECT_ID('Fact.FactPurchaseOrders')
      AND name = 'UQ_FactPurchaseOrders_DetailID'
)
BEGIN

    ALTER TABLE Fact.FactPurchaseOrders
    ADD CONSTRAINT UQ_FactPurchaseOrders_DetailID
    UNIQUE (PurchaseOrderDetailID);

END;
GO

