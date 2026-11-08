USE EnterpriseBI_DW;
GO

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN
(
    'DimProduct',
    'DimLocation',
    'DimScrapReason',
    'DimTransactionType',
    'DimDate',
    'FactInventorySnapshot',
    'FactInventoryTransaction',
    'FactWorkOrder',
    'FactPurchaseOrders'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;
GO