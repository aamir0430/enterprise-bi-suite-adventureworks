# Project Decisions

## Decision 01: Source Database Selection

**Decision:** Use the raw `AdventureWorks2025` OLTP database as the primary source for the Enterprise Business Intelligence Suite.

## Decision 02: Separate Data Warehouse

**Decision:** Create a dedicated SQL Server database named `Enterprise BI DW` to store the project's analytical fact and dimension tables.

## Decision 03: Dimensional Modeling

**Decision:** Develop custom fact and dimension tables using raw data from AdventureWorks2025.

The data warehouse includes three business domains:

* **Sales:** Sales-related fact and dimension tables.
* **Finance:** Finance-related fact and dimension tables.
* **Human Resources (HR):** HR-related fact and dimension tables.

All these tables are maintained in the `Enterprise BI DW` database.
