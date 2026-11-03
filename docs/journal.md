# Project Development Journal

This journal records the major development activities, implementation milestones, and technical challenges encountered during the development of the Enterprise Business Intelligence Suite.

## 29–31 October 2026: Database Setup and Dimensional Modeling

* Selected the raw `AdventureWorks2025` OLTP database as the primary source.
* Created a separate SQL Server database named `Enterprise BI DW`.
* Used raw data from AdventureWorks2025 to create custom fact and dimension tables for:

  * Sales
  * Finance
  * Human Resources (HR)
* Organized the SQL table creation scripts in `sql/02_warehouse/`.

## 31 October – 3 November 2026: Supply Chain Implementation

* Created fact and dimension tables for the Supply Chain business domain.
* Added dimensions including `DimLocation`, `DimScrapReason`, and `DimTransactionType`.
* Created `FactInventorySnapshot`, `FactInventoryTransaction`, and `FactWorkOrder`.
* Reused the existing `FactPurchaseOrders` table where appropriate.
* Resolved a SQL Server collation conflict in `FactInventoryTransaction` by applying `COLLATE DATABASE_DEFAULT`.

## 1–3 November 2026: Data Cleaning and Shaping

Completed data cleaning and shaping in Power Query for the fact and dimension tables across all four business domains:

* Sales
* Finance
* Human Resources (HR)
* Supply Chain

The work included examining data types, null values, duplicates, column quality, and unnecessary columns, and applying the required transformations.

## 2–3 November 2026: Star Schema Design

Designed five different star schema layouts in Power BI Model View:

1. **Sales Star Schema:** Sales fact and dimension tables with their relationships.
2. **Finance Star Schema:** Finance fact and dimension tables with their relationships.
3. **HR Star Schema:** HR fact and dimension tables with their relationships.
4. **Supply Chain Star Schema:** Supply Chain fact and dimension tables with their relationships.
5. **Enterprise Overview:** A combined view of the fact and dimension tables across all four business domains, showing their relationships within the integrated analytical model.

The diagrams are organized under `docs/diagrams/star_schema/`.

## Technical Challenges and Resolutions

### 1. Date Range Mismatch in HR Fact Tables

**Problem:** The dates in `FactEmployeeDepartmentHistory` and `FactEmployeePayHistory` did not match the available date range in `DimDate`.

**Resolution:**

* Extended the date range in `DimDate`.
* Updated the `DimDate` table.
* Rewrote the SQL queries for `FactEmployeeDepartmentHistory` and `FactEmployeePayHistory` to align with the updated date dimension.

**Outcome:** The updated tables and date relationships are now working correctly.

### 2. Power Query and Power BI Model Synchronization

**Problem:** Changes made to `DimDate` in Power Query were not appearing correctly in Power BI Desktop Model View. The updated `FactEmployeeDepartmentHistory` and `FactEmployeePayHistory` tables were also not reflecting the expected changes.

**Resolution:** Addressed the refresh and model synchronization issues and verified the updated tables and their relationships in Power BI Desktop.

**Outcome:** The updated date dimension and related HR fact tables are now reflected correctly in the model.

---

## Current Project Milestone

The following work has been completed:

* Source database selection and target warehouse creation.
* Fact and dimension table creation for Sales, Finance, HR, and Supply Chain.
* SQL script organization in `sql/02_warehouse/`.
* Data cleaning and shaping for all four business domains in Power Query.
* Five star schema layouts designed in Power BI.
* Resolution of the identified SQL date-range, collation, and Power BI model synchronization issues.

**The project has completed its initial database development, data preparation, and dimensional modeling stages.**
