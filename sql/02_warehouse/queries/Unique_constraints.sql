USE EnterpriseBI_DW
GO

ALTER TABLE Dim.DimCustomer
ADD CONSTRAINT UQ_DimCustomer_CustomerID
UNIQUE (CustomerID);

ALTER TABLE Dim.DimProduct
ADD CONSTRAINT UQ_DimProduct_ProductID
UNIQUE (ProductID);

ALTER TABLE Dim.DimSalesTerritory
ADD CONSTRAINT UQ_DimSalesTerritory_TerritoryID
UNIQUE (TerritoryID);

ALTER TABLE Dim.DimSalesPerson
ADD CONSTRAINT UQ_DimSalesPerson_SalesPersonID
UNIQUE (SalesPersonID);

ALTER TABLE Dim.DimPromotion
ADD CONSTRAINT UQ_DimPromotion_SpecialOfferID
UNIQUE (SpecialOfferID);

ALTER TABLE Dim.DimCurrency
ADD CONSTRAINT UQ_DimCurrency_CurrencyCode
UNIQUE (CurrencyCode);

ALTER TABLE Dim.DimShipMethod
ADD CONSTRAINT UQ_DimShipMethod_ShipMethodID
UNIQUE (ShipMethodID);

ALTER TABLE Dim.DimAddress
ADD CONSTRAINT UQ_DimAddress_AddressID
UNIQUE (AddressID);
GO