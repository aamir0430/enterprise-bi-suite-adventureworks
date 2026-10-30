USE EnterpriseBI_DW
GO

ALTER TABLE Fact.FactSales
ADD CONSTRAINT FK_FactSales_Customer
FOREIGN KEY (CustomerKey)
REFERENCES Dim.DimCustomer(CustomerKey);

ALTER TABLE Fact.FactSales
ADD CONSTRAINT FK_FactSales_Product
FOREIGN KEY (ProductKey)
REFERENCES Dim.DimProduct(ProductKey);

ALTER TABLE Fact.FactSales
ADD CONSTRAINT FK_FactSales_Territory
FOREIGN KEY (SalesTerritoryKey)
REFERENCES Dim.DimSalesTerritory(SalesTerritoryKey);

ALTER TABLE Fact.FactSales
ADD CONSTRAINT FK_FactSales_SalesPerson
FOREIGN KEY (SalesPersonKey)
REFERENCES Dim.DimSalesPerson(SalesPersonKey);

ALTER TABLE Fact.FactSales
ADD CONSTRAINT FK_FactSales_Promotion
FOREIGN KEY (PromotionKey)
REFERENCES Dim.DimPromotion(PromotionKey);

ALTER TABLE Fact.FactSales
ADD CONSTRAINT FK_FactSales_Currency
FOREIGN KEY (CurrencyKey)
REFERENCES Dim.DimCurrency(CurrencyKey);

ALTER TABLE Fact.FactSales
ADD CONSTRAINT FK_FactSales_ShipMethod
FOREIGN KEY (ShipMethodKey)
REFERENCES Dim.DimShipMethod(ShipMethodKey);

ALTER TABLE Fact.FactSales
ADD CONSTRAINT FK_FactSales_BillToAddress
FOREIGN KEY (BillToAddressKey)
REFERENCES Dim.DimAddress(AddressKey);

ALTER TABLE Fact.FactSales
ADD CONSTRAINT FK_FactSales_ShipToAddress
FOREIGN KEY (ShipToAddressKey)
REFERENCES Dim.DimAddress(AddressKey);

ALTER TABLE Fact.FactSales
ADD CONSTRAINT FK_FactSales_OrderDate
FOREIGN KEY (OrderDateKey)
REFERENCES Dim.DimDate(DateKey);

ALTER TABLE Fact.FactSales
ADD CONSTRAINT FK_FactSales_DueDate
FOREIGN KEY (DueDateKey)
REFERENCES Dim.DimDate(DateKey);

ALTER TABLE Fact.FactSales
ADD CONSTRAINT FK_FactSales_ShipDate
FOREIGN KEY (ShipDateKey)
REFERENCES Dim.DimDate(DateKey);
GO