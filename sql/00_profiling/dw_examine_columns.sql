USE AdventureWorksDW2025;
GO

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'FactInternetSales',
    'DimDate',
    'DimCustomer',
    'DimProduct',
    'DimSalesTerritory',
    'DimPromotion'
)
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;


