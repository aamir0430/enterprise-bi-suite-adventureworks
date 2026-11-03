# Project Decisions

This document records the major architectural and implementation decisions made during the development of the Enterprise Business Intelligence Suite.

## 1. Source Database Selection

**Decision:** Use the raw `AdventureWorks2025` OLTP database as the primary source instead of the prebuilt `AdventureWorksDW2025` data warehouse.

## 2. Separate Data Warehouse

**Decision:** Create a dedicated SQL Server database named `Enterprise BI DW`.

**Purpose:** Store custom-designed fact and dimension tables using raw data from AdventureWorks2025 while keeping the source database separate.

## 3. Dimensional Modeling

**Decision:** Follow Star Schema principles for designing the analytical data warehouse.

**Implementation:** Create fact and dimension tables for four business domains:

* Sales
* Finance
* Human Resources (HR)
* Supply Chain

## 4. SQL Script Organization

**Decision:** Maintain warehouse schema creation scripts in a dedicated SQL folder.

**Implementation:** Store the fact and dimension table creation scripts in `sql/02_warehouse/`.

## 5. Data Cleaning and Shaping

**Decision:** Use Power Query to clean and shape the analytical data before proceeding with the reporting implementation.

**Implementation:** Complete data cleaning and shaping for the Sales, Finance, HR, and Supply Chain fact and dimension tables.

## 6. Star Schema Documentation

**Decision:** Maintain separate star schema diagrams for each business domain, along with a combined Enterprise Overview.

**Implementation:** Five Power BI model layouts have been designed:

1. Sales Star Schema
2. Finance Star Schema
3. HR Star Schema
4. Supply Chain Star Schema
5. Enterprise Overview – Combined analytical model

**Documentation Location:** `docs/diagrams/star_schema/`

The Enterprise Overview presents the integrated fact and dimension tables and their relationships across the four business domains.

---

*This document will be updated as further architectural and implementation decisions are made.*
