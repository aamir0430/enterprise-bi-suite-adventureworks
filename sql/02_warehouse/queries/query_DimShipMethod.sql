USE EnterpriseBI_DW;
GO

DROP TABLE IF EXISTS Dim.DimShipMethod;
GO

SELECT
    IDENTITY(INT, 1, 1) AS ShipMethodKey,

    CAST(ShipMethodID AS INT) AS ShipMethodID,

    Name AS ShipMethodName,
    ShipBase,
    ShipRate

INTO Dim.DimShipMethod

FROM AdventureWorks2025.Purchasing.ShipMethod;
GO