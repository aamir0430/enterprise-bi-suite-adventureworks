# Decisions

Date | Decision | Reason

26 Oct | Use AdventureWorks (OLTP + DW) | Covers sales, finance, HR and supply chain; has territories for RLS
26 Oct | SQL Server 2025 | Matches the AdventureWorks2025 backups
26 Oct | Build own star schema from OLTP; use DW to validate | Shows design skills; gives accuracy numbers

## 27 Oct 2026: Use AdventureWorksDW2025 as the base for the star schema

**Decision:** I am choosing the AdventureWorksDW2025 database for designing the star schema.

**Reason:** AdventureWorksDW2025 already categorizes the data into fact and dimension tables, which is the structure required for a star schema.

**Supersedes:** the 26 Oct decision to build my own star schema from the OLTP database (AdventureWorks2025) and use the DW only for validation.