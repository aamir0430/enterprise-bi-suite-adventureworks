# Build journal

## 26 Oct 2026: Environment setup
- Installed SQL Server 2025 and SSMS; restored AdventureWorks2025 and AdventureWorksDW2025.
- Validation: row counts recorded in tests/01_restore_validation.sql.

## 27 Oct 2026: Star schema design in AdventureWorksDW2025
- Chose AdventureWorksDW2025 for designing the star schema, because it is already organised into fact and dimension tables.
- Examined the columns of the DW tables and inspected the product hierarchy in DimProduct (DimProduct -> DimProductSubcategory -> DimProductCategory).
- Selected the tables for the model: FactInternetSales, DimCustomer, DimDate, DimProduct, DimProductSubcategory, DimProductCategory, DimPromotion and DimSalesTerritory (reasons in decisions.md).
- In Power Query, merged DimProductSubcategory and DimProductCategory into DimProduct so the product hierarchy sits in a single dimension.
- Cleaning and shaping the data in Power Query: in progress, not finished yet.