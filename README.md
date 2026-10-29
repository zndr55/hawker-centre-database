# Hawker Centre Management Database

A SQL Server database from my Databases module. It has 18 tables covering hawker centres and their operators, stalls and stall owners, customers, orders and menu items, cuisines, promotions, feedback and complaints, NEA inspections and rental agreements. Tables have primary and foreign keys, and NRIC columns are unique. The sample data is made up.

## Files

- `01_schema_and_data.sql`: creates the database, the tables and the sample data
- `02_queries.sql`: queries using joins, subqueries, GROUP BY and HAVING, for example stalls with a current promotion, agreements per stall owner, and owners whose average rental is above 2000

## Running it

Open both files in SQL Server Management Studio and run `01` first, then `02`.
