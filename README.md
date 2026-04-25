# AdventureWorks Sales Performance Analysis

## Project Overview

This project simulates a real-world data analyst workflow using SQL to analyse internet sales performance within the AdventureWorksDW2025 data warehouse. The aim is to transform raw transactional data into actionable insights that support business decision-making around sales strategy, profitability, and resource allocation. The project follows an end-to-end analytics process, including problem definition, data preparation, exploratory analysis, and dashboard development. The analysis focuses on internet sales over a three-year period (2011–2013), with an emphasis on understanding the key drivers of growth across both products and regions.

---

## Business Request

To simulate a realistic business environment, the project was initiated by generating an executive-level business request. This approach replicates how data analysts typically receive high-level, slightly vague, outcome-focused problems from stakeholders, rather than clearly defined technical tasks.

The following request was used as the starting point:

> “We’ve seen decent top-line growth recently, but I’m not convinced we fully understand what’s driving it.
> 
> I’d like a clearer view of how we’re performing across products and regions. Specifically, I want to understand:
> 
> - Where revenue growth is really coming from
> - Whether that growth is translating into healthy margins
> - Which areas of the business are underperforming
> - Where we should be focusing sales effort and investment going into next year
> 
> I don’t need anything overly complex — I need something that helps us prioritise and make decisions."

---

## Project Scope

Following the initial business request, the scope of the analysis was refined through stakeholder-style clarification questions to ensure a focused and decision-relevant approach:

- **Primary Decision** – Determine where to prioritise sales resources and investment for the upcoming year
- **Timeframe** – Analysis covers the last three full years (2011–2013), focusing on year-over-year trends rather than short-term fluctuations
- **Sales Channel** – Internet sales only, as this channel shows the most growth and offers greater strategic flexibility
- **Performance Focus** – Evaluate revenue growth alongside relative profitability to identify areas outperforming or underperforming the overall business
- **Level of Analysis** – Product (Category → Subcategory → Product) and Region (Territory Group → Country), with drill-down where necessary
- **Deliverables** – Interactive Power BI dashboard and a concise summary of key insights and business recommendations

---

## Project Objectives

Building on the defined project scope, the objectives of this analysis focus on supporting data-driven decision-making around sales strategy and resource allocation:

- Analyse overall sales performance to identify key trends over time
- Evaluate whether growth is supported by sustainable profitability
- Identify the product categories and subcategories driving sales performance
- Assess regional contributions to revenue and growth
- Highlight areas of underperformance across products and regions
- Provide clear, actionable insights to guide sales prioritisation and investment decisions

---

## Key Metrics

Following the definition of the project objectives, the key metrics were selected to evaluate sales performance and support the analysis:

- **Revenue** – Total value of sales generated
- **Profit** – Revenue minus cost
- **Profit Margin** – Profit as a percentage of revenue
- **Units Sold** – Total quantity of products sold
- **Orders** – Number of sales transactions
- **Average Order Value** – Average revenue generated per order

---

## Data Source

The analysis uses the AdventureWorksDW2025 data warehouse, a Microsoft sample dataset designed to simulate a real-world business environment. It contains transactional sales data along with product, date, customer, and regional information.

Source: https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure

---

## Data Model

The analysis is based on a star schema data model within the AdventureWorksDW2025 data warehouse, integrating transactional sales data with product, date, and regional information.

- **FactInternetSales** – transactional sales data containing order-level details, including product, date, quantity, revenue, and cost  
- **DimDate** – date attributes used for time-based analysis, including year, quarter, and month  
- **DimProduct** – product-level details, including product name and associated subcategory  
- **DimProductSubcategory** – grouping of products into subcategories  
- **DimProductCategory** – high-level product categories  
- **DimSalesTerritory** – regional information, including territory group, country, and region  

The FactInternetSales table acts as the central fact table, linking product, date, and territory dimensions to each transaction. These relationships enable sales performance to be analysed across time, product hierarchies, and geographic regions.

A curated reporting view (`rpt.vw_internet_sales_reporting`) was used to combine these tables into a single, analysis-ready dataset at the sales order line level.

---

## Analysis Workflow

### 1. Data Discovery

### 2. Data Preparation

### 3. Overall Sales Performance Analysis

### 4. Product Performance Analysis

### 5. Territory Performance Analysis

---

## Key Insights

---

## Recommendations

---

## Dashboard

---

## Repository Contents
