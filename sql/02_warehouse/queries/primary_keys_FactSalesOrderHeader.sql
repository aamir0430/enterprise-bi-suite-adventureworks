USE EnterpriseBI_DW;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE parent_object_id = OBJECT_ID('Fact.FactSalesOrderHeader')
      AND type = 'PK'
)
BEGIN
    ALTER TABLE Fact.FactSalesOrderHeader
    ADD CONSTRAINT PK_FactSalesOrderHeader
    PRIMARY KEY (SalesOrderHeaderKey);
END
GO

ALTER TABLE Fact.FactSalesOrderHeader
ADD CONSTRAINT UQ_FactSalesOrderHeader_SalesOrderID
UNIQUE (SalesOrderID);
GO