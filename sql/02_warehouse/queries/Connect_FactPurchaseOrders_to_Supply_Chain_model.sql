USE EnterpriseBI_DW;
GO

-- Vendor relationship
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys
WHERE name = 'FK_PurchaseOrders_Vendor')
ALTER TABLE Fact.FactPurchaseOrders
ADD CONSTRAINT FK_PurchaseOrders_Vendor
FOREIGN KEY (VendorKey) REFERENCES Dim.DimVendor(VendorKey);
GO

-- Product relationship
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys
WHERE name = 'FK_PurchaseOrders_Product')
ALTER TABLE Fact.FactPurchaseOrders
ADD CONSTRAINT FK_PurchaseOrders_Product
FOREIGN KEY (ProductKey) REFERENCES Dim.DimProduct(ProductKey);
GO

-- Employee relationship
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys
WHERE name = 'FK_PurchaseOrders_Employee')
ALTER TABLE Fact.FactPurchaseOrders
ADD CONSTRAINT FK_PurchaseOrders_Employee
FOREIGN KEY (EmployeeKey) REFERENCES Dim.DimEmployee(EmployeeKey);
GO

-- Shipping method relationship
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys
WHERE name = 'FK_PurchaseOrders_ShipMethod')
ALTER TABLE Fact.FactPurchaseOrders
ADD CONSTRAINT FK_PurchaseOrders_ShipMethod
FOREIGN KEY (ShipMethodKey) REFERENCES Dim.DimShipMethod(ShipMethodKey);
GO

-- Order date relationship
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys
WHERE name = 'FK_PurchaseOrders_OrderDate')
ALTER TABLE Fact.FactPurchaseOrders
ADD CONSTRAINT FK_PurchaseOrders_OrderDate
FOREIGN KEY (OrderDateKey) REFERENCES Dim.DimDate(DateKey);
GO

-- Due date relationship
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys
WHERE name = 'FK_PurchaseOrders_DueDate')
ALTER TABLE Fact.FactPurchaseOrders
ADD CONSTRAINT FK_PurchaseOrders_DueDate
FOREIGN KEY (DueDateKey) REFERENCES Dim.DimDate(DateKey);
GO