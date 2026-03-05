/* ============================================================
   File: 04_analysis_product_performance.sql
   Project: AdventureWorks Sales Performance Analysis
   Purpose: Analyse product performance for internet sales over
            the last three full years (2011–2013) using the
            curated reporting view.
   Produces: 1) category performance + revenue contribution
             2) bikes subcategory performance + revenue contribution
             3) bikes subcategory yearly performance + YoY growth
             4) top 20 products by revenue
             5) bottom 20 products by profit margin
   ============================================================ */

-- USE AdventureWorksDW2025;
-- GO

------------------------------------------------------------
-- 1) category performance + revenue contribution
------------------------------------------------------------
WITH category_totals AS (
    SELECT
        product_category,
        SUM(revenue) AS revenue,
        SUM(profit)  AS profit,
        SUM(units_sold) AS units_sold,
        COUNT(DISTINCT SalesOrderNumber) AS orders
    FROM rpt.vw_internet_sales_reporting
    WHERE calendar_year BETWEEN 2011 AND 2013
    GROUP BY product_category
),

grand_total AS (
    SELECT SUM(revenue) AS total_revenue
    FROM category_totals
)

SELECT
    c.product_category,
    c.revenue,
    CASE
        WHEN g.total_revenue = 0 THEN NULL
        ELSE c.revenue * 1.0 / g.total_revenue
    END AS revenue_contribution_pct,
    c.profit,
    CASE
        WHEN c.revenue = 0 THEN NULL
        ELSE c.profit * 1.0 / c.revenue
    END AS profit_margin,
    c.units_sold,
    c.orders,
    CASE
        WHEN c.orders = 0 THEN NULL
        ELSE c.revenue * 1.0 / c.orders
    END AS average_order_value
FROM category_totals c
CROSS JOIN grand_total g
ORDER BY c.revenue DESC;

------------------------------------------------------------
-- 2) bikes subcategory performance + revenue contribution
------------------------------------------------------------
WITH subcategory_totals AS (
    SELECT
        product_subcategory,
        SUM(revenue) AS revenue,
        SUM(profit)  AS profit,
        SUM(units_sold) AS units_sold,
        COUNT(DISTINCT SalesOrderNumber) AS orders
    FROM rpt.vw_internet_sales_reporting
    WHERE calendar_year BETWEEN 2011 AND 2013
      AND product_category = 'Bikes'
    GROUP BY product_subcategory
),
bikes_total AS (
    SELECT SUM(revenue) AS total_revenue
    FROM subcategory_totals
)
SELECT
    s.product_subcategory,
    s.revenue,
    CASE
        WHEN b.total_revenue = 0 THEN NULL
        ELSE s.revenue * 1.0 / b.total_revenue
    END AS revenue_contribution_pct,
    s.profit,
    CASE
        WHEN s.revenue = 0 THEN NULL
        ELSE s.profit * 1.0 / s.revenue
    END AS profit_margin,
    s.units_sold,
    s.orders,
    CASE
        WHEN s.orders = 0 THEN NULL
        ELSE s.revenue * 1.0 / s.orders
    END AS average_order_value
FROM subcategory_totals s
CROSS JOIN bikes_total b
ORDER BY s.revenue DESC;

------------------------------------------------------------
-- 3) bikes subcategory yearly performance + YoY growth
------------------------------------------------------------
WITH subcat_yearly AS (
    SELECT
        calendar_year,
        product_subcategory,
        SUM(revenue) AS revenue,
        SUM(profit)  AS profit,
        CASE
            WHEN SUM(revenue) = 0 THEN NULL
            ELSE SUM(profit) * 1.0 / SUM(revenue)
        END AS profit_margin
    FROM rpt.vw_internet_sales_reporting
    WHERE calendar_year BETWEEN 2011 AND 2013
      AND product_category = 'Bikes'
    GROUP BY calendar_year, product_subcategory
)
SELECT
    calendar_year,
    product_subcategory,
    revenue,
    CASE
        WHEN LAG(revenue) OVER (PARTITION BY product_subcategory ORDER BY calendar_year) IS NULL THEN NULL
        WHEN LAG(revenue) OVER (PARTITION BY product_subcategory ORDER BY calendar_year) = 0 THEN NULL
        ELSE (revenue - LAG(revenue) OVER (PARTITION BY product_subcategory ORDER BY calendar_year)) * 1.0
             / LAG(revenue) OVER (PARTITION BY product_subcategory ORDER BY calendar_year)
    END AS revenue_yoy_growth,
    profit,
    CASE
        WHEN LAG(profit) OVER (PARTITION BY product_subcategory ORDER BY calendar_year) IS NULL THEN NULL
        WHEN LAG(profit) OVER (PARTITION BY product_subcategory ORDER BY calendar_year) = 0 THEN NULL
        ELSE (profit - LAG(profit) OVER (PARTITION BY product_subcategory ORDER BY calendar_year)) * 1.0
             / LAG(profit) OVER (PARTITION BY product_subcategory ORDER BY calendar_year)
    END AS profit_yoy_growth,
    profit_margin
FROM subcat_yearly
ORDER BY product_subcategory, calendar_year;

------------------------------------------------------------
-- 4) top 20 products by revenue
------------------------------------------------------------
SELECT TOP (20)
    product_category,
    product_subcategory,
    product_name,
    SUM(revenue) AS revenue,
    SUM(profit)  AS profit,
    CASE
        WHEN SUM(revenue) = 0 THEN NULL
        ELSE SUM(profit) * 1.0 / SUM(revenue)
    END AS profit_margin,
    SUM(units_sold) AS units_sold
FROM rpt.vw_internet_sales_reporting
WHERE calendar_year BETWEEN 2011 AND 2013
GROUP BY
    product_category,
    product_subcategory,
    product_name
ORDER BY revenue DESC;

------------------------------------------------------------
-- 5) bottom 20 products by profit margin
--    note: adjust threshold to reduce low-volume noise
------------------------------------------------------------
WITH product_totals AS (
    SELECT
        product_category,
        product_subcategory,
        product_name,
        SUM(revenue) AS revenue,
        SUM(profit)  AS profit,
        SUM(units_sold) AS units_sold
    FROM rpt.vw_internet_sales_reporting
    WHERE calendar_year BETWEEN 2011 AND 2013
    GROUP BY
        product_category,
        product_subcategory,
        product_name
)
SELECT TOP (20)
    product_category,
    product_subcategory,
    product_name,
    revenue,
    profit,
    CASE
        WHEN revenue = 0 THEN NULL
        ELSE profit * 1.0 / revenue
    END AS profit_margin,
    units_sold
FROM product_totals
WHERE revenue >= 10000 -- threshold
ORDER BY profit_margin ASC;