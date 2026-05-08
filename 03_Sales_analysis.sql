/*  
Sales Analysis:
Performed sales analysis using SQL Server to identify revenue trends, top-performing stores, leading vendors, best-selling products, 
product-size contribution, monthly growth, and ABC product segmentation.
Zero-value sales records were handled separately to keep revenue and average price calculations accurate while preserving quantity movement for inventory analysis.
*/

USE RetailVendorInventoryDB;
GO

-- ============================================================
-- 1. OVERALL SALES KPIs
-- Purpose: Understand total sales performance of the business
-- ============================================================

SELECT
    ROUND(SUM(SalesDollars), 2) AS TotalSales,
    ROUND(SUM(SalesQuantity), 2) AS TotalSalesQuantity,
    COUNT(*) AS TotalSalesTransactions,
    COUNT(DISTINCT Store) AS TotalStores,
    COUNT(DISTINCT Brand) AS TotalBrands,
    COUNT(DISTINCT VendorNo) AS TotalVendors,
    ROUND(SUM(ExciseTax), 2) AS TotalExciseTax,
    ROUND(SUM(SalesDollars) / NULLIF(SUM(SalesQuantity), 0), 2) AS AvgSellingPrice
FROM dbo.clean_sales
WHERE SalesDollars > 0; -- there are some 0 values in sales

/*
The business generated $452.06M in sales across 80 stores, 127 vendors, and 11,237 brands/products, 
indicating a large multi-store retail operation with a broad product portfolio.
*/


-- ============================================================
-- 2. MONTHLY SALES TREND
-- Purpose: Analyze sales performance by month
-- ============================================================

SELECT
    YEAR(SalesDate) AS SalesYear,
    MONTH(SalesDate) AS SalesMonth,
    DATENAME(MONTH, SalesDate) AS MonthName,
    ROUND(SUM(SalesDollars), 2) AS TotalSales,
    ROUND(SUM(SalesQuantity), 2) AS TotalSalesQuantity,
    COUNT(*) AS TransactionCount
FROM dbo.clean_sales
WHERE SalesDollars > 0
GROUP BY
    YEAR(SalesDate),
    MONTH(SalesDate),
    DATENAME(MONTH, SalesDate)
ORDER BY
    SalesYear,
    SalesMonth;

/*
Monthly trend analysis showed strong seasonality, with sales peaking in July and December.
December recorded the highest monthly sales at $52.31M, while February was the weakest month at $28.88M.
*/


-- ============================================================
-- 3. MONTH-OVER-MONTH SALES GROWTH
-- Purpose: Compare monthly sales with previous month
-- ============================================================

WITH MonthlySales AS (
    SELECT
        YEAR(SalesDate) AS SalesYear,
        MONTH(SalesDate) AS SalesMonth,
        DATENAME(MONTH, SalesDate) AS MonthName,
        ROUND(SUM(SalesDollars), 2) AS TotalSales
    FROM dbo.clean_sales
    WHERE SalesDollars > 0
    GROUP BY
        YEAR(SalesDate),
        MONTH(SalesDate),
        DATENAME(MONTH, SalesDate)
),

MonthlyGrowth AS (
    SELECT
        SalesYear,
        SalesMonth,
        MonthName,
        TotalSales,
        LAG(TotalSales) OVER (ORDER BY SalesYear, SalesMonth) AS PreviousMonthSales
    FROM MonthlySales
)

SELECT
    SalesYear,
    SalesMonth,
    MonthName,
    TotalSales,
    PreviousMonthSales,
    ROUND(TotalSales - PreviousMonthSales, 2) AS SalesChange,
    ROUND(
        (TotalSales - PreviousMonthSales) / NULLIF(PreviousMonthSales, 0) * 100,
        2
    ) AS MoMGrowthPct
FROM MonthlyGrowth
ORDER BY SalesYear, SalesMonth;


/*
Month-over-month analysis showed the strongest growth in July (+26.48%) and December (+23.63%), 
while August saw a sharp correction of -21.41% after the July peak.
*/



-- ============================================================
-- 4. TOP STORES BY SALES
-- Purpose: Identify highest revenue-generating stores
-- ============================================================

SELECT TOP 10
    Store,
    ROUND(SUM(SalesDollars), 2) AS TotalSales,
    ROUND(SUM(SalesQuantity), 2) AS TotalSalesQuantity,
    COUNT(*) AS TransactionCount,
    ROUND(SUM(SalesDollars) / NULLIF(SUM(SalesQuantity), 0), 2) AS AvgSellingPrice
FROM dbo.clean_sales
WHERE SalesDollars > 0
GROUP BY Store
ORDER BY TotalSales DESC;

-- ============================================================
-- 5. LOWEST SALES STORES
-- Purpose: Identify stores with low sales performance
-- ============================================================

SELECT TOP 10
    Store,
    ROUND(SUM(SalesDollars), 2) AS TotalSales,
    ROUND(SUM(SalesQuantity), 2) AS TotalSalesQuantity,
    COUNT(*) AS TransactionCount
FROM dbo.clean_sales
WHERE SalesDollars > 0
GROUP BY Store
ORDER BY TotalSales ASC;

/*
Store-level analysis showed strong sales concentration, with the top 10 stores contributing approximately 38.6% of total sales.
Store 76 was the highest-performing store with $25.45M in sales, while Store 3 had the lowest sales at $419.73K.
*/

-- ============================================================
-- 6. TOP VENDORS BY SALES
-- Purpose: Identify vendors contributing the most revenue
-- ============================================================

SELECT TOP 10
    VendorNo,
    VendorName,
    ROUND(SUM(SalesDollars), 2) AS TotalSales,
    ROUND(SUM(SalesQuantity), 2) AS TotalSalesQuantity,
    COUNT(DISTINCT Brand) AS TotalBrandsSold,
    ROUND(SUM(SalesDollars) / NULLIF(SUM(SalesQuantity), 0), 2) AS AvgSellingPrice
FROM dbo.clean_sales
WHERE SalesDollars > 0
GROUP BY VendorNo, VendorName
ORDER BY TotalSales DESC;

/*
Insight:
The top vendor, DIAGEO NORTH AMERICA INC, contributes 15.21% of total sales.
The top 10 vendors together contribute around 65% of total revenue.
*/

-- ============================================================
-- 7. TOP PRODUCTS BY SALES
-- Purpose: Identify highest revenue-generating products
-- ============================================================

SELECT TOP 10
    Brand,
    Description,
    Size,
    ROUND(SUM(SalesDollars), 2) AS TotalSales,
    ROUND(SUM(SalesQuantity), 2) AS TotalSalesQuantity,
    COUNT(DISTINCT Store) AS StoresSellingProduct,
    ROUND(SUM(SalesDollars) / NULLIF(SUM(SalesQuantity), 0), 2) AS AvgSellingPrice
FROM dbo.clean_sales
WHERE SalesDollars > 0
GROUP BY Brand, Description, Size
ORDER BY TotalSales DESC;

/*
Insight:
Large bottle sizes, especially 1.75L, dominate the top revenue products. Jack Daniels No 7 Black,Tito's Handmade Vodka &
Absolut 80 Proof are the top revenue generating products */


-- ============================================================
-- 8. TOP PRODUCTS BY QUANTITY SOLD
-- Purpose: Identify products with highest unit demand
-- ============================================================

SELECT TOP 10
    Brand,
    Description,
    Size,
    ROUND(SUM(SalesQuantity), 2) AS TotalSalesQuantity,
    ROUND(SUM(SalesDollars), 2) AS TotalSales,
    ROUND(SUM(SalesDollars) / NULLIF(SUM(SalesQuantity), 0), 2) AS AvgSellingPrice
FROM dbo.clean_sales
WHERE SalesDollars > 0
GROUP BY Brand, Description, Size
ORDER BY TotalSalesQuantity DESC;

/*
Quantity analysis showed that 50mL products generated the highest unit sales, while 1.75L products generated the highest revenue. 
This highlights the difference between volume-driving products and revenue-driving products.
*/


-- ============================================================
-- 9. SALES BY CLASSIFICATION
-- Purpose: Compare sales performance across product classes
-- ============================================================

SELECT
    Classification,
    ROUND(SUM(SalesDollars), 2) AS TotalSales,
    ROUND(SUM(SalesQuantity), 2) AS TotalSalesQuantity,
    COUNT(DISTINCT Brand) AS TotalBrands,
    ROUND(SUM(SalesDollars) / NULLIF(SUM(SalesQuantity), 0), 2) AS AvgSellingPrice
FROM dbo.clean_sales
WHERE SalesDollars > 0
GROUP BY Classification
ORDER BY TotalSales DESC;

/*
Classification 1 outperformed Classification 2 in both total revenue and average selling price,
contributing $290.17M compared to $161.90M.
*/

-- ============================================================
-- 10. SALES BY PRODUCT SIZE
-- Purpose: Identify which product sizes contribute most to sales
-- ============================================================

SELECT TOP 15
    Size,
    ROUND(SUM(SalesDollars), 2) AS TotalSales,
    ROUND(SUM(SalesQuantity), 2) AS TotalSalesQuantity,
    COUNT(DISTINCT Brand) AS TotalBrands,
    ROUND(SUM(SalesDollars) / NULLIF(SUM(SalesQuantity), 0), 2) AS AvgSellingPrice
FROM dbo.clean_sales
WHERE SalesDollars > 0
GROUP BY Size
ORDER BY TotalSales DESC;

/*
Size analysis showed that 750mL products generated the highest sales at $253.98M, followed by 1.75L products at $132.10M. 
Smaller 50mL products had high unit movement but lower revenue contribution due to low average selling price.
*/


-- ============================================================
-- 11. VENDOR SALES CONTRIBUTION %
-- Purpose: Understand vendor dependency and revenue concentration
-- ============================================================

WITH VendorSales AS (
    SELECT
        VendorNo,
        VendorName,
        ROUND(SUM(SalesDollars), 2) AS TotalSales
    FROM dbo.clean_sales
    WHERE SalesDollars > 0
    GROUP BY VendorNo, VendorName
),

TotalSales AS (
    SELECT SUM(TotalSales) AS OverallSales
    FROM VendorSales
)

SELECT TOP 15
    vs.VendorNo,
    vs.VendorName,
    vs.TotalSales,
    ROUND(vs.TotalSales / NULLIF(ts.OverallSales, 0) * 100, 2) AS SalesContributionPct
FROM VendorSales vs
CROSS JOIN TotalSales ts
ORDER BY vs.TotalSales DESC;

/*
Insight:
The top vendor, DIAGEO NORTH AMERICA INC, contributes 15.21% of total sales.
Revenue is highly concentrated, with the top 15 of 80 vendors contributing nearly 77% of total sales

Business interpretation:
Vendor dependency is high. The business should maintain strong relationships with top vendors but also monitor over-dependence risk.
*/


-- ============================================================
-- 12. PRODUCT SALES CONTRIBUTION %
-- Purpose: Identify product dependency and top product contribution
-- ============================================================

WITH ProductSales AS (
    SELECT
        Brand,
        Description,
        Size,
        ROUND(SUM(SalesDollars), 2) AS TotalSales
    FROM dbo.clean_sales
    WHERE SalesDollars > 0
    GROUP BY Brand, Description, Size
),

TotalSales AS (
    SELECT SUM(TotalSales) AS OverallSales
    FROM ProductSales
)

SELECT TOP 20
    ps.Brand,
    ps.Description,
    ps.Size,
    ps.TotalSales,
    ROUND(ps.TotalSales / NULLIF(ts.OverallSales, 0) * 100, 2) AS SalesContributionPct
FROM ProductSales ps
CROSS JOIN TotalSales ts
ORDER BY ps.TotalSales DESC;

/*
Insights:
Top 3 product contributes only 4% of Total Sales

Business interpretation:
Revenue is not dependent on just one or two products. The business has a diversified product portfolio.
*/

-- ============================================================
-- 13. ABC ANALYSIS - PRODUCT REVENUE SEGMENTATION
-- Purpose: Classify products based on cumulative revenue contribution
-- A = Top products contributing up to 70% revenue
-- B = Next products contributing up to 90% revenue
-- C = Remaining long-tail products
-- ============================================================

WITH ProductSales AS (
    SELECT
        Brand,
        Description,
        Size,
        ROUND(SUM(SalesDollars), 2) AS TotalSales
    FROM dbo.clean_sales
    WHERE SalesDollars > 0
    GROUP BY Brand, Description, Size
),

ProductContribution AS (
    SELECT
        Brand,
        Description,
        Size,
        TotalSales,
        ROUND(
            SUM(TotalSales) OVER (ORDER BY TotalSales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            / NULLIF(SUM(TotalSales) OVER (), 0) * 100,
            2
        ) AS CumulativeSalesPct
    FROM ProductSales
)

SELECT
    Brand,
    Description,
    Size,
    TotalSales,
    CumulativeSalesPct,
    CASE
        WHEN CumulativeSalesPct <= 70 THEN 'A - Core Revenue Products'
        WHEN CumulativeSalesPct <= 90 THEN 'B - Mid Revenue Products'
        ELSE 'C - Long Tail Products'
    END AS ABCClass
FROM ProductContribution
ORDER BY TotalSales DESC;

/*
A relatively small group of products drives 70% of revenue, while many products fall into the long-tail category.
ABC analysis showed that a limited number of products contribute the majority of revenue.
A-class products should be prioritized for stock availability while C-class products should be reviewed for slow movement and inventory holding risk.
*/


-- ============================================================
-- 14. ZERO-VALUE SALES ANALYSIS
-- Purpose: Analyze sales records where quantity exists but sales amount is zero
-- ============================================================

SELECT
    Brand,
    Description,
    Size,
    VendorNo,
    VendorName,
    COUNT(*) AS ZeroValueTransactionCount,
    ROUND(SUM(SalesQuantity), 2) AS ZeroValueSalesQuantity,
    ROUND(SUM(ExciseTax), 2) AS RelatedExciseTax
FROM dbo.clean_sales
WHERE SalesQuantity > 0
  AND SalesDollars = 0
  AND SalesPrice = 0
GROUP BY
    Brand,
    Description,
    Size,
    VendorNo,
    VendorName
ORDER BY ZeroValueSalesQuantity DESC;

/*
Zero-value sales records were analyzed separately because they affect quantity and inventory movement but should not impact revenue, 
average selling price, or margin calculations.
*/


--## Sales Analysis Summary

--I found that the business generated $452.06M in sales from 12.83M transactions across 80 stores, 127 vendors, and 11,237 brands/products.
--Monthly sales showed clear seasonality, with sales peaking in July and December.
--December was the highest sales month at $52.31M, while February was the weakest month at $28.88M.

--At the store level, I found that sales were concentrated among top-performing stores.
--The top 10 stores contributed approximately 38.6% of total sales, led by Store 76 with $25.45M.

--Vendor-level analysis showed stronger concentration.
--The top 15 vendors, out of 80 vendors, contributed approximately 76.82% of total revenue.
--DIAGEO NORTH AMERICA INC was the leading vendor, contributing 15.21% of total sales.

--Product analysis showed that 1.75L products dominated revenue rankings, while 50mL products drove the highest unit sales.
--Size-level analysis showed that 750mL products generated the highest revenue, followed by 1.75L products.

--ABC analysis helped me identify the core products that contribute the majority of revenue, while the remaining products form a long-tail segment.
--I kept zero-value sales records separate so that financial KPIs remain accurate while quantity movement can still be used for inventory analysis.
