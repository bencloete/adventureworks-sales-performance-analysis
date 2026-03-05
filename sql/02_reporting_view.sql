/* ============================================================
   File: 02_reporting_view.sql
   Project: AdventureWorks Sales Performance Analysis
   Purpose: Create a reporting layer by joining FactInternetSales
            to key dimensions and standardising measures ready for 
            analysis and dashboarding.
   ============================================================ */

-- USE AdventureWorksDW2025;
-- GO

------------------------------------------------------------
-- 1) create reporting schema
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'rpt')
    EXEC('CREATE SCHEMA rpt');
GO

------------------------------------------------------------
-- 2) create reporting view for internet sales
------------------------------------------------------------
CREATE OR ALTER VIEW rpt.vw_internet_sales_reporting
AS
SELECT
    -- order identifiers
    f.SalesOrderNumber,
    f.SalesOrderLineNumber,

    -- date attributes
    d.FullDateAlternateKey AS order_date,
    d.CalendarYear AS calendar_year,
    d.CalendarQuarter AS calendar_quarter,
    d.MonthNumberOfYear AS month_number,

    -- product attributes
    pc.EnglishProductCategoryName AS product_category,
    ps.EnglishProductSubcategoryName AS product_subcategory,
    p.EnglishProductName AS product_name,

    -- territory attributes
    st.SalesTerritoryGroup AS territory_group,
    st.SalesTerritoryCountry AS country,
    st.SalesTerritoryRegion AS region,

    -- base measures
    f.OrderQuantity AS units_sold,
    f.SalesAmount AS revenue,
    f.TotalProductCost AS cost,

    -- calculated measures
    (f.SalesAmount - f.TotalProductCost) AS profit,
    CASE
        WHEN f.SalesAmount = 0 THEN NULL
        ELSE (f.SalesAmount - f.TotalProductCost) / f.SalesAmount
    END AS profit_margin

FROM 
    dbo.FactInternetSales f
    JOIN dbo.DimDate d ON f.OrderDateKey = d.DateKey
    JOIN dbo.DimProduct p ON f.ProductKey = p.ProductKey
    LEFT JOIN dbo.DimProductSubcategory ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    LEFT JOIN dbo.DimProductCategory pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
    JOIN dbo.DimSalesTerritory st ON f.SalesTerritoryKey = st.SalesTerritoryKey;
GO

------------------------------------------------------------
-- 3) validation queries
------------------------------------------------------------

-- A) inspect view
SELECT 
    TOP (10) *
FROM 
    rpt.vw_internet_sales_reporting
ORDER BY
    order_date DESC,
    SalesOrderNumber DESC,
    SalesOrderLineNumber DESC;

-- B) confirm view row count
SELECT COUNT(*) AS view_row_count
FROM rpt.vw_internet_sales_reporting;

-- C) confirm view date range
SELECT
    MIN(order_date) AS min_order_date,
    MAX(order_date) AS max_order_date
FROM 
    rpt.vw_internet_sales_reporting;

-- D) confirm view year coverage
SELECT
    calendar_year,
    COUNT(DISTINCT SalesOrderNumber) AS orders,
    COUNT(*) AS order_lines,
    SUM(revenue) AS revenue
FROM 
    rpt.vw_internet_sales_reporting
GROUP BY 
    calendar_year
ORDER BY 
    calendar_year;