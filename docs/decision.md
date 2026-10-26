# Decisions

Date | Decision | Reason

26 Oct | Use AdventureWorks (OLTP + DW) | Covers sales, finance, HR and supply chain; has territories for RLS
26 Oct | SQL Server 2025 | Matches the AdventureWorks2025 backups
26 Oct | Build own star schema from OLTP; use DW to validate | Shows design skills; gives accuracy numbers