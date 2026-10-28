# Decisions

## 26 Oct 2026: 
**1. Use AdventureWorks (OLTP + DW)**
**Reason:** Covers sales, finance, HR and supply chain; has territories for RLS

**2. SQL Server 2025** 
**Reason:** Matches the AdventureWorks2025 backups

**3. Build own star schema from OLTP; use DW to validate**
**Reason:** Shows design skills; gives accuracy numbers

## 27 Oct 2026: Use AdventureWorksDW2025 as the base for the star schema

**Decision:** I am choosing the AdventureWorksDW2025 database for designing the star schema.

**Reason:** AdventureWorksDW2025 already categorizes the data into fact and dimension tables, which is the structure required for a star schema.

**Supersedes:** the 26 Oct decision to build my own star schema from the OLTP database (AdventureWorks2025) and use the DW only for validation.

## 27 Oct 2026: Tables selected for the star schema

**Decision:** The model uses one fact table, FactInternetSales, with these dimensions: DimDate, DimCustomer, DimProduct, DimProductSubcategory, DimProductCategory, DimPromotion and DimSalesTerritory.

**Reasons:**
- **FactInternetSales:** one row per internet sales order line, with the sales amount, quantity and product cost needed for revenue, margin and growth measures.
- **DimDate:** required for time intelligence (YTD, year-over-year growth, rolling averages) through its relationships to the order, due and ship dates.
- **DimProduct, DimProductSubcategory, DimProductCategory:** needed to analyse sales by product, subcategory and category.
- **DimCustomer:** needed to analyse sales by customer.
- **DimPromotion:** needed to measure the effect of promotions and discounts on sales.
- **DimSalesTerritory:** needed for regional analysis, and it is the basis for row-level security so each region manager sees only their own data.


## 28 Oct 2026: Merge product subcategory and category into DimProduct

**Decision:** In Power Query, DimProductSubcategory and DimProductCategory are merged into DimProduct, giving one flat product dimension.

**Reasons:**
- In the source, the product hierarchy is split across three linked tables (a snowflake). Merging them gives a true star schema, with every dimension linked directly to the fact table.
- A single product dimension means fewer relationships in the model, simpler DAX and a cleaner field list for report users.
- Product, subcategory and category can be used together in one slicer or drill-down hierarchy.

## 28 Oct 2026: Investigate before deleting rows

**Decision:** In Power Query, no rows are deleted from FactInternetSales without evidence that they are invalid. Suspicious values (negative amounts, unmatched keys, nulls) are investigated against the source first.

**Reasons:**
- Each row is a sales order line, so removing rows changes revenue totals and the business meaning of the data.
- Some unusual values can be valid adjustments, and some unmatched keys can be valid "unknown" members.
- The cleaned table can then be reconciled exactly against the source totals recorded in tests/data_quality/.


## 28 Oct 2026: Columns kept in FactInternetSales

**Decision:** FactInternetSales keeps these columns:
- Keys: ProductKey, OrderDateKey, DueDateKey, ShipDateKey, CustomerKey, PromotionKey, SalesTerritoryKey
- Order identification: SalesOrderNumber, SalesOrderLineNumber
- Measures: OrderQuantity, UnitPrice, ExtendedAmount, UnitPriceDiscountPct, DiscountAmount, TotalProductCost, SalesAmount, TaxAmt, Freight, RevisionNumber
- Dates: OrderDate, DueDate and ShipDate columns

Removed: CarrierTrackingNumber, CustomerPONumber, CurrencyKey.

**Reasons:**
- Kept columns support the KPIs: revenue, units, discounts, margin (from TotalProductCost), and analysis by date, product, customer, promotion and territory.
- CarrierTrackingNumber, CustomerPONumber are operational references that no business question uses.
- CurrencyKey is removed because reporting uses the amounts as stored, with no currency conversion in scope.


## 29 Oct 2026: Explicit data types in Power Query

**Decision:** Data types are set explicitly: keys, line numbers and quantities as Whole Number; money columns (prices, amounts, costs, tax, freight) as Fixed Decimal Number/Currency; discount percentage as Decimal Number; identifiers as Text.

**Reasons:**
- Automatic type detection can guess wrong when the data changes.
- Fixed Decimal Number avoids the floating-point rounding errors that can affect financial totals.