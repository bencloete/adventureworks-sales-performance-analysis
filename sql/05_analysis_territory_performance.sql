/* ============================================================
   File: 05_analysis_territory_performance.sql
   Project: AdventureWorks Sales Performance Analysis
   Purpose: Analyse territory performance for internet sales over
            the last three full years (2011–2013) using the
            curated reporting view.
   Produces: 1) territory group performance + revenue contribution
             2) territory group yearly performance + YoY growth
             3) North America regional performance + revenue contribution
             4) North America monthly performance + YoY monthly growth
   ============================================================ */

-- USE AdventureWorksDW2025;
-- GO

------------------------------------------------------------
-- 1) territory group performance + revenue contribution
------------------------------------------------------------
WITH territory_totals AS (
    SELECT
        territory_group,
        SUM(revenue) AS revenue,
        SUM(profit) AS profit,
        SUM(units_sold) AS units_sold,
        COUNT(DISTINCT SalesOrderNumber) AS orders
    FROM rpt.vw_internet_sales_reporting
    WHERE calendar_year BETWEEN 2011 AND 2013
    GROUP BY territory_group
),

grand_total AS (
    SELECT SUM(revenue) AS total_revenue
    FROM territory_totals
)

SELECT
    t.territory_group,
    t.revenue,
    CASE
        WHEN g.total_revenue = 0 THEN NULL
        ELSE t.revenue * 1.0 / g.total_revenue
    END AS revenue_contribution_pct,
    t.profit,
    CASE
        WHEN t.revenue = 0 THEN NULL
        ELSE t.profit * 1.0 / t.revenue
    END AS profit_margin,
    t.units_sold,
    t.orders,
    CASE
        WHEN t.orders = 0 THEN NULL
        ELSE t.revenue * 1.0 / t.orders
    END AS average_order_value
FROM territory_totals t
CROSS JOIN grand_total g
ORDER BY t.revenue DESC;

------------------------------------------------------------
-- 2) territory group yearly performance + YoY growth
------------------------------------------------------------
WITH territory_yearly AS (
    SELECT
        calendar_year,
        territory_group,
        SUM(revenue) AS revenue,
        SUM(profit) AS profit,
        CASE
            WHEN SUM(revenue) = 0 THEN NULL
            ELSE SUM(profit) * 1.0 / SUM(revenue)
        END AS profit_margin
    FROM rpt.vw_internet_sales_reporting
    WHERE calendar_year BETWEEN 2011 AND 2013
    GROUP BY
        calendar_year,
        territory_group
)

SELECT
    calendar_year,
    territory_group,
    revenue,
    CASE
        WHEN LAG(revenue) OVER (PARTITION BY territory_group ORDER BY calendar_year) IS NULL THEN NULL
        WHEN LAG(revenue) OVER (PARTITION BY territory_group ORDER BY calendar_year) = 0 THEN NULL
        ELSE (revenue - LAG(revenue) OVER (PARTITION BY territory_group ORDER BY calendar_year)) * 1.0
             / LAG(revenue) OVER (PARTITION BY territory_group ORDER BY calendar_year)
    END AS revenue_yoy_growth,
    profit,
    CASE
        WHEN LAG(profit) OVER (PARTITION BY territory_group ORDER BY calendar_year) IS NULL THEN NULL
        WHEN LAG(profit) OVER (PARTITION BY territory_group ORDER BY calendar_year) = 0 THEN NULL
        ELSE (profit - LAG(profit) OVER (PARTITION BY territory_group ORDER BY calendar_year)) * 1.0
             / LAG(profit) OVER (PARTITION BY territory_group ORDER BY calendar_year)
    END AS profit_yoy_growth,
    profit_margin
FROM territory_yearly
ORDER BY territory_group, calendar_year;

------------------------------------------------------------
-- 3) North America regional performance + revenue contribution
------------------------------------------------------------
WITH region_totals AS (
    SELECT
        region,
        SUM(revenue) AS revenue,
        SUM(profit) AS profit,
        SUM(units_sold) AS units_sold,
        COUNT(DISTINCT SalesOrderNumber) AS orders
    FROM rpt.vw_internet_sales_reporting
    WHERE calendar_year BETWEEN 2011 AND 2013
      AND territory_group = 'North America'
    GROUP BY region
),

na_total AS (
    SELECT SUM(revenue) AS total_revenue
    FROM region_totals
)

SELECT
    r.region,
    r.revenue,
    CASE
        WHEN n.total_revenue = 0 THEN NULL
        ELSE r.revenue * 1.0 / n.total_revenue
    END AS revenue_contribution_pct,
    r.profit,
    CASE
        WHEN r.revenue = 0 THEN NULL
        ELSE r.profit * 1.0 / r.revenue
    END AS profit_margin,
    r.units_sold,
    r.orders,
    CASE
        WHEN r.orders = 0 THEN NULL
        ELSE r.revenue * 1.0 / r.orders
    END AS average_order_value
FROM region_totals r
CROSS JOIN na_total n
ORDER BY r.revenue DESC;

------------------------------------------------------------
-- 4) North America monthly performance + YoY monthly growth
------------------------------------------------------------
WITH monthly AS (
    SELECT
        calendar_year,
        month_number,
        SUM(revenue) AS revenue,
        SUM(profit) AS profit
    FROM rpt.vw_internet_sales_reporting
    WHERE territory_group = 'North America'
      AND calendar_year BETWEEN 2011 AND 2013
    GROUP BY
        calendar_year,
        month_number
)

SELECT
    calendar_year,
    month_number,
    revenue,
    LAG(revenue) OVER (
        PARTITION BY month_number
        ORDER BY calendar_year
    ) AS revenue_prev_year,
    CASE
        WHEN LAG(revenue) OVER (PARTITION BY month_number ORDER BY calendar_year) IS NULL THEN NULL
        WHEN LAG(revenue) OVER (PARTITION BY month_number ORDER BY calendar_year) = 0 THEN NULL
        ELSE (revenue - LAG(revenue) OVER (PARTITION BY month_number ORDER BY calendar_year)) * 1.0
             / LAG(revenue) OVER (PARTITION BY month_number ORDER BY calendar_year)
    END AS revenue_yoy_growth,
    profit,
    LAG(profit) OVER (
        PARTITION BY month_number
        ORDER BY calendar_year
    ) AS profit_prev_year,
    CASE
        WHEN LAG(profit) OVER (PARTITION BY month_number ORDER BY calendar_year) IS NULL THEN NULL
        WHEN LAG(profit) OVER (PARTITION BY month_number ORDER BY calendar_year) = 0 THEN NULL
        ELSE (profit - LAG(profit) OVER (PARTITION BY month_number ORDER BY calendar_year)) * 1.0
             / LAG(profit) OVER (PARTITION BY month_number ORDER BY calendar_year)
    END AS profit_yoy_growth
FROM monthly
ORDER BY month_number, calendar_year;