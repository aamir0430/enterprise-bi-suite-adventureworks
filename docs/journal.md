# Project Development Journal

## 30 October 2026

### Work Completed

1. **Source Database Selection:** Selected the raw `AdventureWorks2025` OLTP database as the primary source for the project.

2. **Data Warehouse Creation:** Created a separate SQL Server database named `Enterprise BI DW` to store the project's analytical data.

3. **Dimensional Modeling:** Used raw data from AdventureWorks2025 to create custom fact and dimension tables for three business domains:

   * Sales
   * Finance
   * Human Resources (HR)

4. **SQL Script Organization:** Organized all fact and dimension table creation scripts in the GitHub repository under `sql/02_warehouse/`.

**Current Milestone:** Source database selection, target database creation, and initial Sales, Finance, and HR dimensional modeling completed.
