/* ============================================================
   File: 03_analysis_overall_performance.sql
   Project: AdventureWorks Sales Performance Analysis
   Purpose: Analyse overall internet sales performance for the
            last three full years (2011–2013) using the curated
            reporting view. Produces an executive KPI overview,
            a yearly performance scorecard with YoY growth,
            and monthly trend analysis.
   ============================================================ */

-- USE AdventureWorksDW2025;
-- GO

------------------------------------------------------------
-- 1) KPI overview
------------------------------------------------------------
SELECT
    SUM(revenue) AS total_revenue,
    SUM(profit)  AS total_profit,
    CASE
        WHEN SUM(revenue) = 0 THEN NULL
        ELSE SUM(profit) / SUM(revenue)
    END AS profit_margin,
    SUM(units_sold) AS total_units_sold,
    COUNT(DISTINCT SalesOrderNumber) AS total_orders,
    CASE
        WHEN COUNT(DISTINCT SalesOrderNumber) = 0 THEN NULL
        ELSE SUM(revenue) / COUNT(DISTINCT SalesOrderNumber)
    END AS average_order_value
FROM rpt.vw_internet_sales_reporting
WHERE calendar_year BETWEEN 2011 AND 2013;

------------------------------------------------------------
-- 2) yearly performance scorecard
------------------------------------------------------------
WITH yearly AS (
    SELECT
        calendar_year,
        SUM(revenue) AS revenue,
        SUM(profit)  AS profit,
        CASE
            WHEN SUM(revenue) = 0 THEN NULL
            ELSE SUM(profit) / SUM(revenue)
        END AS profit_margin,
        SUM(units_sold) AS units_sold,
        COUNT(DISTINCT SalesOrderNumber) AS orders,
        CASE
            WHEN COUNT(DISTINCT SalesOrderNumber) = 0 THEN NULL
            ELSE SUM(revenue) / COUNT(DISTINCT SalesOrderNumber)
        END AS average_order_value
    FROM rpt.vw_internet_sales_reporting
    WHERE calendar_year BETWEEN 2011 AND 2013
    GROUP BY calendar_year
)

SELECT
    calendar_year,
    revenue,
    CASE
        WHEN LAG(revenue) OVER (ORDER BY calendar_year) IS NULL THEN NULL
        WHEN LAG(revenue) OVER (ORDER BY calendar_year) = 0 THEN NULL
        ELSE (revenue - LAG(revenue) OVER (ORDER BY calendar_year))
             / LAG(revenue) OVER (ORDER BY calendar_year)
    END AS revenue_yoy_growth,
    profit,
    CASE
        WHEN LAG(profit) OVER (ORDER BY calendar_year) IS NULL THEN NULL
        WHEN LAG(profit) OVER (ORDER BY calendar_year) = 0 THEN NULL
        ELSE (profit - LAG(profit) OVER (ORDER BY calendar_year))
             / LAG(profit) OVER (ORDER BY calendar_year)
    END AS profit_yoy_growth,
    profit_margin,
    units_sold,
    orders,
    average_order_value
FROM yearly
ORDER BY calendar_year;

------------------------------------------------------------
-- 3) monthly trend analysis
------------------------------------------------------------
SELECT
    calendar_year,
    month_number,
    SUM(revenue) AS revenue,
    SUM(profit)  AS profit,
    CASE
        WHEN SUM(revenue) = 0 THEN NULL
        ELSE SUM(profit) / SUM(revenue)
    END AS profit_margin,
    SUM(units_sold) AS units_sold,
    COUNT(DISTINCT SalesOrderNumber) AS orders,
    CASE
        WHEN COUNT(DISTINCT SalesOrderNumber) = 0 THEN NULL
        ELSE SUM(revenue) / COUNT(DISTINCT SalesOrderNumber)
    END AS average_order_value
FROM rpt.vw_internet_sales_reporting
WHERE calendar_year BETWEEN 2011 AND 2013
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number;