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

## 28 Oct 2026: Cleaning, shaping and validating the data

- **Cleaned and shaped FactInternetSales and the other model tables in Power Query:** set explicit data types (keys and quantities as whole numbers, money columns as currency), removed columns not needed for the reporting KPIs, and checked column quality and distribution for nulls and errors.

- **Approach:** investigate suspicious values before deleting anything. Rows are removed only with evidence that they are invalid.

- **Ran SQL validation checks against AdventureWorksDW2025 (scripts in tests/data_quality/):** nulls in key fields, duplicate order lines (SalesOrderNumber + SalesOrderLineNumber), suspicious numeric values, and unmatched product, customer, order date, promotion and territory keys.

- Recorded baseline totals from the source to compare with Power BI later.

**| Check | Result | Action taken |**

| Nulls in key fields | None found | None |
| Duplicate order lines | None found | None |
| Suspicious numeric values | None found | None |
| Unmatched keys (product, customer, order date, promotion, territory) | None found | None |
| Baseline: total rows / distinct orders | None found / None found | Recorded for reconciliation |
| Baseline: total sales / total product cost | None found / None found | Recorded for reconciliation |