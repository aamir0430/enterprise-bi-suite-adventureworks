USE EnterpriseBI_DW;
GO

SELECT
    SCHEMA_NAME(T.schema_id) AS SchemaName,
    T.name AS TableName,
    C.column_id AS ColumnNumber,
    C.name AS ColumnName,
    TYPE_NAME(C.user_type_id) AS DataType,
    C.max_length AS MaxLength,
    C.is_nullable AS IsNullable,
    C.is_identity AS IsIdentity
FROM sys.tables T
INNER JOIN sys.columns C
    ON T.object_id = C.object_id
WHERE T.name IN (
    'DimEmployee',
    'DimDepartment',
    'DimShift',
    'DimPayFrequency',
    'DimDate',
    'FactEmployeeSnapshot',
    'FactEmployeeDepartmentHistory',
    'FactEmployeePayHistory'
)
ORDER BY
    SchemaName,
    TableName,
    ColumnNumber;
GO
