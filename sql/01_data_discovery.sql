/* ============================================================
   File: 01_data_discovery.sql
   Project: AdventureWorks Sales Performance Analysis
   Purpose: Explore the AdventureWorksDW schema and validate the
            structure, grain, time coverage, data quality, and
            join integrity of the internet sales dataset and its
            supporting dimension tables prior to building the
            reporting layer and performing analysis.
   ============================================================ */

-- USE AdventureWorksDW2025;
-- GO

------------------------------------------------------------
-- 1) confirm current database
------------------------------------------------------------
SELECT DB_NAME() AS current_database;

------------------------------------------------------------
-- 2) inspect fact table
------------------------------------------------------------
SELECT TOP (10) *
FROM dbo.FactInternetSales;

------------------------------------------------------------
-- 3) inspect dimension tables
------------------------------------------------------------
SELECT TOP (10) *
FROM dbo.DimDate;

SELECT TOP (10) *
FROM dbo.DimProduct;

SELECT TOP (10) *
FROM dbo.DimProductSubcategory;

SELECT TOP (10) *
FROM dbo.DimProductCategory;

SELECT TOP (10) *
FROM dbo.DimSalesTerritory;

------------------------------------------------------------
-- 4) confirm grain
------------------------------------------------------------
SELECT
    COUNT(DISTINCT SalesOrderNumber) AS orders,
    COUNT(*) AS row_count,
    COUNT(DISTINCT CONCAT(SalesOrderNumber, '-', SalesOrderLineNumber)) AS distinct_order_lines
FROM 
    dbo.FactInternetSales;

------------------------------------------------------------
-- 5) check time coverage
------------------------------------------------------------

-- A) check date range
SELECT 
    MIN(d.FullDateAlternateKey) AS min_order_date,
    MAX(d.FullDateAlternateKey) AS max_order_date
FROM 
    dbo.FactInternetSales f 
    JOIN dbo.DimDate d ON f.OrderDateKey = d.DateKey;

-- B) summarise sales activity by year
SELECT
    d.CalendarYear,
    COUNT(DISTINCT f.SalesOrderNumber) AS orders,
    COUNT(*) AS order_lines,
    SUM(f.SalesAmount) AS revenue,
    SUM(f.SalesAmount - f.TotalProductCost) AS profit
FROM 
    dbo.FactInternetSales f
    JOIN dbo.DimDate d ON f.OrderDateKey = d.DateKey
GROUP BY 
    d.CalendarYear
ORDER BY 
    d.CalendarYear;

-- C) confirm analysis window row count
SELECT
    COUNT(*) AS order_lines_2011_2013
FROM 
    dbo.FactInternetSales f
    JOIN dbo.DimDate d ON f.OrderDateKey = d.DateKey
WHERE 
    d.CalendarYear BETWEEN 2011 AND 2013;

------------------------------------------------------------
-- 6) data quality checks
------------------------------------------------------------

-- A) check for nulls in key columns used for joins and identifiers
SELECT
    SUM(CASE WHEN OrderDateKey IS NULL THEN 1 ELSE 0 END) AS null_orderdatekey,
    SUM(CASE WHEN ProductKey IS NULL THEN 1 ELSE 0 END) AS null_productkey,
    SUM(CASE WHEN SalesTerritoryKey IS NULL THEN 1 ELSE 0 END) AS null_salesterritorykey,
    SUM(CASE WHEN SalesOrderNumber IS NULL THEN 1 ELSE 0 END) AS null_salesordernumber,
    SUM(CASE WHEN SalesOrderLineNumber IS NULL THEN 1 ELSE 0 END) AS null_salesorderlinenumber
FROM 
    dbo.FactInternetSales;

-- B) check for nulls in key measures
SELECT
    SUM(CASE WHEN SalesAmount IS NULL THEN 1 ELSE 0 END) AS null_salesamount,
    SUM(CASE WHEN TotalProductCost IS NULL THEN 1 ELSE 0 END) AS null_totalproductcost,
    SUM(CASE WHEN OrderQuantity IS NULL THEN 1 ELSE 0 END) AS null_orderquantity
FROM 
    dbo.FactInternetSales;

-- C) sanity checks on key measures
SELECT
    SUM(CASE WHEN SalesAmount < 0 THEN 1 ELSE 0 END) AS neg_salesamount,
    SUM(CASE WHEN TotalProductCost < 0 THEN 1 ELSE 0 END) AS neg_totalproductcost,
    SUM(CASE WHEN OrderQuantity <= 0 THEN 1 ELSE 0 END) AS non_pos_orderquantity
FROM 
    dbo.FactInternetSales;

------------------------------------------------------------
-- 7) join integrity checks
------------------------------------------------------------

-- A) check for fact rows without a matching DimProduct record
SELECT 
    COUNT(*) AS orphan_product_rows
FROM 
    dbo.FactInternetSales f
    LEFT JOIN dbo.DimProduct p ON f.ProductKey = p.ProductKey
WHERE 
    p.ProductKey IS NULL;

-- B) check for fact rows without a matching DimDate record
SELECT 
    COUNT(*) AS orphan_date_rows
FROM 
    dbo.FactInternetSales f
    LEFT JOIN dbo.DimDate d ON f.OrderDateKey = d.DateKey
WHERE 
    d.DateKey IS NULL;

-- C) check for fact rows without a matching DimSalesTerritory record
SELECT 
    COUNT(*) AS orphan_territory_rows
FROM 
    dbo.FactInternetSales f
    LEFT JOIN dbo.DimSalesTerritory t ON f.SalesTerritoryKey = t.SalesTerritoryKey
WHERE 
    t.SalesTerritoryKey IS NULL;