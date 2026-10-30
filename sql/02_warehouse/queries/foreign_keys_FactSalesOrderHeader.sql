USE EnterpriseBI_DW
GO

ALTER TABLE Fact.FactSalesOrderHeader
ADD CONSTRAINT FK_FactSalesOrderHeader_Customer
FOREIGN KEY (CustomerKey)
REFERENCES Dim.DimCustomer(CustomerKey);

ALTER TABLE Fact.FactSalesOrderHeader
ADD CONSTRAINT FK_FactSalesOrderHeader_Territory
FOREIGN KEY (SalesTerritoryKey)
REFERENCES Dim.DimSalesTerritory(SalesTerritoryKey);

ALTER TABLE Fact.FactSalesOrderHeader
ADD CONSTRAINT FK_FactSalesOrderHeader_SalesPerson
FOREIGN KEY (SalesPersonKey)
REFERENCES Dim.DimSalesPerson(SalesPersonKey);

ALTER TABLE Fact.FactSalesOrderHeader
ADD CONSTRAINT FK_FactSalesOrderHeader_ShipMethod
FOREIGN KEY (ShipMethodKey)
REFERENCES Dim.DimShipMethod(ShipMethodKey);

ALTER TABLE Fact.FactSalesOrderHeader
ADD CONSTRAINT FK_FactSalesOrderHeader_BillAddress
FOREIGN KEY (BillToAddressKey)
REFERENCES Dim.DimAddress(AddressKey);

ALTER TABLE Fact.FactSalesOrderHeader
ADD CONSTRAINT FK_FactSalesOrderHeader_ShipAddress
FOREIGN KEY (ShipToAddressKey)
REFERENCES Dim.DimAddress(AddressKey);

ALTER TABLE Fact.FactSalesOrderHeader
ADD CONSTRAINT FK_FactSalesOrderHeader_OrderDate
FOREIGN KEY (OrderDateKey)
REFERENCES Dim.DimDate(DateKey);

ALTER TABLE Fact.FactSalesOrderHeader
ADD CONSTRAINT FK_FactSalesOrderHeader_DueDate
FOREIGN KEY (DueDateKey)
REFERENCES Dim.DimDate(DateKey);

ALTER TABLE Fact.FactSalesOrderHeader
ADD CONSTRAINT FK_FactSalesOrderHeader_ShipDate
FOREIGN KEY (ShipDateKey)
REFERENCES Dim.DimDate(DateKey);
GO