USE EnterpriseBI_DW;
GO

-- DimCustomer
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimCustomer')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimCustomer
    ADD CONSTRAINT PK_DimCustomer
    PRIMARY KEY (CustomerKey);
END;
GO

-- DimProduct
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimProduct')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimProduct
    ADD CONSTRAINT PK_DimProduct
    PRIMARY KEY (ProductKey);
END;
GO

-- DimDate
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimDate')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimDate
    ADD CONSTRAINT PK_DimDate
    PRIMARY KEY (DateKey);
END;
GO

-- DimSalesTerritory
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimSalesTerritory')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimSalesTerritory
    ADD CONSTRAINT PK_DimSalesTerritory
    PRIMARY KEY (SalesTerritoryKey);
END;
GO

-- DimSalesPerson
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimSalesPerson')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimSalesPerson
    ADD CONSTRAINT PK_DimSalesPerson
    PRIMARY KEY (SalesPersonKey);
END;
GO

-- DimPromotion
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimPromotion')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimPromotion
    ADD CONSTRAINT PK_DimPromotion
    PRIMARY KEY (PromotionKey);
END;
GO

-- DimCurrency
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimCurrency')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimCurrency
    ADD CONSTRAINT PK_DimCurrency
    PRIMARY KEY (CurrencyKey);
END;
GO

-- DimShipMethod
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimShipMethod')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimShipMethod
    ADD CONSTRAINT PK_DimShipMethod
    PRIMARY KEY (ShipMethodKey);
END;
GO

-- DimAddress
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Dim.DimAddress')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Dim.DimAddress
    ADD CONSTRAINT PK_DimAddress
    PRIMARY KEY (AddressKey);
END;
GO