-- Purchase and Vendor Analysis:
--Performed SQL-based purchase and vendor analysis to evaluate purchase spend, vendor dependency, freight cost impact, payment cycles, and procurement efficiency. 
--Compared vendor-level and product-level sales against purchase investment to identify high-spend vendors, slow-moving products, and zero-cost purchase exceptions.

USE RetailVendorInventoryDB;
GO

-- ============================================================
-- 1. OVERALL PURCHASE KPIs
-- Purpose: Understand total purchasing activity
-- ============================================================

SELECT
    ROUND(SUM(Dollars), 2) AS TotalPurchaseDollars,
    ROUND(SUM(Quantity), 2) AS TotalPurchaseQuantity,
    COUNT(*) AS TotalPurchaseRecords,
    COUNT(DISTINCT Store) AS TotalStores,
    COUNT(DISTINCT Brand) AS TotalBrands,
    COUNT(DISTINCT VendorNumber) AS TotalVendors,
    COUNT(DISTINCT PONumber) AS TotalPurchaseOrders,
    ROUND(SUM(Dollars) / NULLIF(SUM(Quantity), 0), 2) AS AvgPurchasePrice
FROM dbo.clean_purchases
WHERE Dollars > 0;

/*
The business purchased $321.90M worth of inventory across 80 stores and 126 vendors.
Compared with our sales of around $452.06M, the business appears to have a positive sales-to-purchase value gap.
*/


-- ============================================================
-- 2. MONTHLY PURCHASE TREND
-- Purpose: Analyze purchase spending by receiving month
-- ============================================================

SELECT
    YEAR(ReceivingDate) AS PurchaseYear,
    MONTH(ReceivingDate) AS PurchaseMonth,
    DATENAME(MONTH, ReceivingDate) AS MonthName,
    ROUND(SUM(Dollars), 2) AS TotalPurchaseDollars,
    ROUND(SUM(Quantity), 2) AS TotalPurchaseQuantity,
    COUNT(DISTINCT PONumber) AS TotalPurchaseOrders
FROM dbo.clean_purchases
WHERE Dollars > 0
GROUP BY
    YEAR(ReceivingDate),
    MONTH(ReceivingDate),
    DATENAME(MONTH, ReceivingDate)
ORDER BY
    PurchaseYear,
    PurchaseMonth;

/*
Purchases were lower in the first quarter and increased strongly from May to December.
This matches our sales seasonality, where sales also increased strongly around July and December.
*/


-- ============================================================
-- 3. MONTH-OVER-MONTH PURCHASE GROWTH
-- Purpose: Compare monthly purchase spend with previous month
-- ============================================================

WITH MonthlyPurchases AS (
    SELECT
        YEAR(ReceivingDate) AS PurchaseYear,
        MONTH(ReceivingDate) AS PurchaseMonth,
        DATENAME(MONTH, ReceivingDate) AS MonthName,
        ROUND(SUM(Dollars), 2) AS TotalPurchaseDollars
    FROM dbo.clean_purchases
    WHERE Dollars > 0
    GROUP BY
        YEAR(ReceivingDate),
        MONTH(ReceivingDate),
        DATENAME(MONTH, ReceivingDate)
),

PurchaseGrowth AS (
    SELECT
        PurchaseYear,
        PurchaseMonth,
        MonthName,
        TotalPurchaseDollars,
        LAG(TotalPurchaseDollars) OVER (
            ORDER BY PurchaseYear, PurchaseMonth
        ) AS PreviousMonthPurchase
    FROM MonthlyPurchases
)

SELECT
    PurchaseYear,
    PurchaseMonth,
    MonthName,
    TotalPurchaseDollars,
    PreviousMonthPurchase,
    ROUND(TotalPurchaseDollars - PreviousMonthPurchase, 2) AS PurchaseChange,
    ROUND(
        (TotalPurchaseDollars - PreviousMonthPurchase)
        / NULLIF(PreviousMonthPurchase, 0) * 100,
        2
    ) AS MoMGrowthPct
FROM PurchaseGrowth
ORDER BY PurchaseYear, PurchaseMonth;

/*
Purchase investment rose sharply in May and July, likely to prepare for high sales periods.
September saw a decline after strong July/August purchasing.
*/


-- ============================================================
-- 4. TOP VENDORS BY PURCHASE SPEND
-- Purpose: Identify vendors with highest purchase cost
-- ============================================================

SELECT TOP 10
    VendorNumber,
    VendorName,
    ROUND(SUM(Dollars), 2) AS TotalPurchaseDollars,
    ROUND(SUM(Quantity), 2) AS TotalPurchaseQuantity,
    COUNT(DISTINCT Brand) AS TotalBrandsPurchased,
    COUNT(DISTINCT PONumber) AS TotalPurchaseOrders,
    ROUND(SUM(Dollars) / NULLIF(SUM(Quantity), 0), 2) AS AvgPurchasePrice
FROM dbo.clean_purchases
WHERE Dollars > 0
GROUP BY
    VendorNumber,
    VendorName
ORDER BY TotalPurchaseDollars DESC;

/*
DIAGEO is the largest purchase vendor and also the largest sales vendor from our sales analysis. 
That means DIAGEO is a high-investment and high-return vendor.
*/


-- ============================================================
-- 5. VENDOR PURCHASE CONTRIBUTION %
-- Purpose: Understand vendor dependency in purchasing
-- ============================================================

WITH VendorPurchases AS (
    SELECT
        VendorNumber,
        VendorName,
        ROUND(SUM(Dollars), 2) AS TotalPurchaseDollars
    FROM dbo.clean_purchases
    WHERE Dollars > 0
    GROUP BY
        VendorNumber,
        VendorName
),

TotalPurchases AS (
    SELECT SUM(TotalPurchaseDollars) AS OverallPurchaseDollars
    FROM VendorPurchases
)

SELECT TOP 15
    vp.VendorNumber,
    vp.VendorName,
    vp.TotalPurchaseDollars,
    ROUND(
        vp.TotalPurchaseDollars / NULLIF(tp.OverallPurchaseDollars, 0) * 100,
        2
    ) AS PurchaseContributionPct
FROM VendorPurchases vp
CROSS JOIN TotalPurchases tp
ORDER BY vp.TotalPurchaseDollars DESC;

/*
Insight:
I found that vendor concentration is very strong in purchasing.
The top 15 vendors contribute approximately 77.33% of total purchase value, 
which is very close to their sales contribution of around 76.82%.

Business Takeaway:
The company should prioritize strong vendor relationship management with these high-contribution vendors.
However, since purchase and sales dependency are both concentrated among the same vendor group, 
the business should also monitor supplier dependency risk and explore opportunities to diversify or improve performance from mid-tier vendors.
*/


-- ============================================================
-- 6. TOP PRODUCTS BY PURCHASE SPEND
-- Purpose: Identify products where the business spends most money
-- ============================================================

SELECT TOP 10
    Brand,
    Description,
    Size,
    ROUND(SUM(Dollars), 2) AS TotalPurchaseDollars,
    ROUND(SUM(Quantity), 2) AS TotalPurchaseQuantity,
    COUNT(DISTINCT VendorNumber) AS VendorCount,
    ROUND(SUM(Dollars) / NULLIF(SUM(Quantity), 0), 2) AS AvgPurchasePrice
FROM dbo.clean_purchases
WHERE Dollars > 0
GROUP BY
    Brand,
    Description,
    Size
ORDER BY TotalPurchaseDollars DESC;

/*
Large-size liquor products dominate purchase spending, which matches our sales analysis where 1.75L products were also among the top revenue drivers.
*/

-- ============================================================
-- 7. TOP PRODUCTS BY PURCHASE QUANTITY
-- Purpose: Identify products purchased in highest unit quantity
-- ============================================================

SELECT TOP 10
    Brand,
    Description,
    Size,
    ROUND(SUM(Quantity), 2) AS TotalPurchaseQuantity,
    ROUND(SUM(Dollars), 2) AS TotalPurchaseDollars,
    ROUND(SUM(Dollars) / NULLIF(SUM(Quantity), 0), 2) AS AvgPurchasePrice
FROM dbo.clean_purchases
WHERE Dollars > 0
GROUP BY
    Brand,
    Description,
    Size
ORDER BY TotalPurchaseQuantity DESC;

/*
Top purchase-quantity products are mainly 50mL items like Smirnoff 80 Proof, Yukon Jack, and Dr McGillicuddy’s. 
This again matches our sales analysis: 50mL products drive unit volume, while 1.75L products drive revenue/value.
*/


-- ============================================================
-- 8. PURCHASE BY STORE
-- Purpose: Identify stores receiving highest purchase investment
-- ============================================================

SELECT TOP 10
    Store,
    ROUND(SUM(Dollars), 2) AS TotalPurchaseDollars,
    ROUND(SUM(Quantity), 2) AS TotalPurchaseQuantity,
    COUNT(DISTINCT Brand) AS TotalBrandsPurchased,
    COUNT(DISTINCT PONumber) AS TotalPurchaseOrders
FROM dbo.clean_purchases
WHERE Dollars > 0
GROUP BY Store
ORDER BY TotalPurchaseDollars DESC;

/*
Store-level purchase analysis showed that the highest-purchase stores were also among the highest-sales stores,
suggesting inventory investment was broadly aligned with store demand.
*/

-- ============================================================
-- 9. PURCHASE BY CLASSIFICATION
-- Purpose: Compare purchasing across product classifications
-- ============================================================

SELECT
    Classification,
    ROUND(SUM(Dollars), 2) AS TotalPurchaseDollars,
    ROUND(SUM(Quantity), 2) AS TotalPurchaseQuantity,
    COUNT(DISTINCT Brand) AS TotalBrandsPurchased,
    ROUND(SUM(Dollars) / NULLIF(SUM(Quantity), 0), 2) AS AvgPurchasePrice
FROM dbo.clean_purchases
WHERE Dollars > 0
GROUP BY Classification
ORDER BY TotalPurchaseDollars DESC;


/*
Classification 1 received the highest purchase investment and also generated the highest sales,
indicating stronger business importance compared to Classification 2.
*/


-- ============================================================
-- 10. OVERALL INVOICE AND FREIGHT KPIs
-- Purpose: Understand vendor invoice value and freight cost impact
-- ============================================================

SELECT
    ROUND(SUM(Dollars), 2) AS TotalInvoiceDollars,
    ROUND(SUM(Quantity), 2) AS TotalInvoiceQuantity,
    ROUND(SUM(Freight), 2) AS TotalFreightCost,
    COUNT(*) AS TotalInvoices,
    COUNT(DISTINCT VendorNumber) AS TotalVendors,
    COUNT(DISTINCT PONumber) AS TotalPurchaseOrders,
    ROUND(SUM(Freight) / NULLIF(SUM(Dollars), 0) * 100, 2) AS FreightPct
FROM dbo.clean_vendor_invoice
WHERE Dollars > 0;

/*
Freight cost is small compared to invoice value. 
Overall freight is only around 0.51%, which means logistics cost is not a major cost burden in this dataset.
*/

-- ============================================================
-- 11. TOP VENDORS BY FREIGHT COST
-- Purpose: Identify vendors with highest logistics/freight cost
-- ============================================================

SELECT TOP 10
    VendorNumber,
    VendorName,
    ROUND(SUM(Freight), 2) AS TotalFreightCost,
    ROUND(SUM(Dollars), 2) AS TotalInvoiceDollars,
    COUNT(DISTINCT PONumber) AS TotalPurchaseOrders,
    ROUND(SUM(Freight) / NULLIF(SUM(Dollars), 0) * 100, 2) AS FreightPct
FROM dbo.clean_vendor_invoice
WHERE Dollars > 0
GROUP BY
    VendorNumber,
    VendorName
ORDER BY TotalFreightCost DESC;

/*
Top freight vendors are mostly the same as top purchase vendors
High freight cost is mainly driven by high purchase volume, not necessarily poor freight efficiency.
*/



-- ============================================================
-- 12. VENDORS WITH HIGHEST FREIGHT %
-- Purpose: Identify vendors where freight cost is high compared to invoice value
-- Note: Minimum invoice value filter avoids misleading small-value vendors
--This is better than only freight amount because a vendor with high purchase value will naturally have high freight.
-- ============================================================

SELECT TOP 10
    VendorNumber,
    VendorName,
    ROUND(SUM(Freight), 2) AS TotalFreightCost,
    ROUND(SUM(Dollars), 2) AS TotalInvoiceDollars,
    ROUND(SUM(Freight) / NULLIF(SUM(Dollars), 0) * 100, 2) AS FreightPct,
    COUNT(DISTINCT PONumber) AS TotalPurchaseOrders
FROM dbo.clean_vendor_invoice
WHERE Dollars > 0
GROUP BY
    VendorNumber,
    VendorName
HAVING SUM(Dollars) >= 10000
ORDER BY FreightPct DESC;

/*
Vendor freight percentage was highly consistent, mostly around 0.50%–0.54%, indicating stable freight cost behavior across vendors.
*/

-- ============================================================
-- 13. MONTHLY FREIGHT TREND
-- Purpose: Analyze freight cost movement by invoice month
-- ============================================================

SELECT
    YEAR(InvoiceDate) AS InvoiceYear,
    MONTH(InvoiceDate) AS InvoiceMonth,
    DATENAME(MONTH, InvoiceDate) AS MonthName,
    ROUND(SUM(Freight), 2) AS TotalFreightCost,
    ROUND(SUM(Dollars), 2) AS TotalInvoiceDollars,
    ROUND(SUM(Freight) / NULLIF(SUM(Dollars), 0) * 100, 2) AS FreightPct
FROM dbo.clean_vendor_invoice
WHERE Dollars > 0
GROUP BY
    YEAR(InvoiceDate),
    MONTH(InvoiceDate),
    DATENAME(MONTH, InvoiceDate)
ORDER BY
    InvoiceYear,
    InvoiceMonth;

/*
January has the highest Freight% ~0.73% rest of the year it is stable around 0.5% 
*/



-- ============================================================
-- 14. OVERALL PAYMENT CYCLE
-- Purpose: Analyze how long the business takes to pay vendor invoices
-- ============================================================

SELECT
    COUNT(*) AS TotalInvoices,
    ROUND(AVG(DATEDIFF(DAY, InvoiceDate, PayDate)), 2) AS AvgPaymentDays,
    MIN(DATEDIFF(DAY, InvoiceDate, PayDate)) AS MinPaymentDays,
    MAX(DATEDIFF(DAY, InvoiceDate, PayDate)) AS MaxPaymentDays
FROM dbo.clean_vendor_invoice
WHERE InvoiceDate IS NOT NULL
  AND PayDate IS NOT NULL;

/*
Payment cycle analysis showed that vendor invoices were paid in an average of 35 days,
with most invoices falling in the range of 31–45 days 
*/


-- ============================================================
-- 15. VENDOR-WISE PAYMENT DAYS
-- Purpose: Identify vendors with longer or shorter payment cycles
-- ============================================================

SELECT TOP 15
    VendorNumber,
    VendorName,
    COUNT(*) AS TotalInvoices,
    ROUND(SUM(Dollars), 2) AS TotalInvoiceDollars,
    ROUND(AVG(DATEDIFF(DAY, InvoiceDate, PayDate)), 2) AS AvgPaymentDays,
    MIN(DATEDIFF(DAY, InvoiceDate, PayDate)) AS MinPaymentDays,
    MAX(DATEDIFF(DAY, InvoiceDate, PayDate)) AS MaxPaymentDays
FROM dbo.clean_vendor_invoice
WHERE InvoiceDate IS NOT NULL
  AND PayDate IS NOT NULL
GROUP BY
    VendorNumber,
    VendorName
HAVING COUNT(*) >= 5
ORDER BY AvgPaymentDays DESC;


/*
Most vendors with the highest average payment days have low invoice values, which reduces the financial risk.
However, MARTIGNETTI COMPANIES, BROWN-FORMAN CORP, and CAMPARI AMERICA have both high invoice values and longer payment periods
*/


-- ============================================================
-- 16. PAYMENT CYCLE BUCKETS
-- Purpose: Segment invoices based on payment delay
-- ============================================================

WITH PaymentData AS (
    SELECT
        VendorNumber,
        VendorName,
        PONumber,
        InvoiceDate,
        PayDate,
        Dollars,
        DATEDIFF(DAY, InvoiceDate, PayDate) AS PaymentDays
    FROM dbo.clean_vendor_invoice
    WHERE InvoiceDate IS NOT NULL
      AND PayDate IS NOT NULL
)

SELECT
    CASE
        WHEN PaymentDays <= 15 THEN '0-15 Days'
        WHEN PaymentDays <= 30 THEN '16-30 Days'
        WHEN PaymentDays <= 45 THEN '31-45 Days'
        WHEN PaymentDays <= 60 THEN '46-60 Days'
        ELSE '60+ Days'
    END AS PaymentBucket,
    COUNT(*) AS InvoiceCount,
    ROUND(SUM(Dollars), 2) AS TotalInvoiceDollars,
    ROUND(AVG(PaymentDays), 2) AS AvgPaymentDays
FROM PaymentData
GROUP BY
    CASE
        WHEN PaymentDays <= 15 THEN '0-15 Days'
        WHEN PaymentDays <= 30 THEN '16-30 Days'
        WHEN PaymentDays <= 45 THEN '31-45 Days'
        WHEN PaymentDays <= 60 THEN '46-60 Days'
        ELSE '60+ Days'
    END
ORDER BY
    MIN(PaymentDays);

/*
Insight:
I found that most vendor payments are concentrated in the 31-45 day bucket,
with 4,051 invoices representing around 73% of total invoices and approximately 74% of total invoice value.

Business Takeaway:
The payment cycle appears stable because most invoices are settled within 31-45 days,
while only a small share falls into the 46-60 day delayed-payment bucket.
*/


-- ============================================================
-- 17. PO TO RECEIVING CYCLE
-- Purpose: Analyze how long it takes to receive goods after purchase order
-- ============================================================

SELECT
    COUNT(*) AS PurchaseRecords,
    ROUND(AVG(DATEDIFF(DAY, PODate, ReceivingDate)), 2) AS AvgDaysToReceive,
    MIN(DATEDIFF(DAY, PODate, ReceivingDate)) AS MinDaysToReceive,
    MAX(DATEDIFF(DAY, PODate, ReceivingDate)) AS MaxDaysToReceive
FROM dbo.clean_purchases
WHERE PODate IS NOT NULL
  AND ReceivingDate IS NOT NULL;

/*
The procurement receiving process looks efficient. On average, stock is received within one week after purchase order creation.
*/

-- ============================================================
-- 18. VENDOR-WISE RECEIVING DELAY
-- Purpose: Identify vendors with slower stock delivery
-- ============================================================

SELECT TOP 15
    VendorNumber,
    VendorName,
    COUNT(DISTINCT PONumber) AS TotalPurchaseOrders,
    ROUND(SUM(Dollars), 2) AS TotalPurchaseDollars,
    ROUND(AVG(DATEDIFF(DAY, PODate, ReceivingDate)), 2) AS AvgDaysToReceive,
    MIN(DATEDIFF(DAY, PODate, ReceivingDate)) AS MinDaysToReceive,
    MAX(DATEDIFF(DAY, PODate, ReceivingDate)) AS MaxDaysToReceive
FROM dbo.clean_purchases
WHERE PODate IS NOT NULL
  AND ReceivingDate IS NOT NULL
  AND Dollars > 0
GROUP BY
    VendorNumber,
    VendorName
HAVING COUNT(DISTINCT PONumber) >= 3
ORDER BY AvgDaysToReceive DESC;

/*
Insight:
The vendor receiving time is mostly concentrated between 8 and 9 days for the slowest vendors.
IRA GOLDMAN AND WILLIAMS, LLP and BLACK COVE BEVERAGES have the highest average receiving time at 9 days.
*/



-- ============================================================
-- 19. VENDOR-LEVEL SALES VS PURCHASE COMPARISON
-- Purpose: Compare vendor revenue contribution with purchase investment
-- ============================================================

WITH VendorSales AS (
    SELECT
        VendorNo AS VendorNumber,
        ROUND(SUM(SalesDollars), 2) AS TotalSalesDollars,
        ROUND(SUM(SalesQuantity), 2) AS TotalSalesQuantity
    FROM dbo.clean_sales
    WHERE SalesDollars > 0
    GROUP BY VendorNo
),

VendorPurchases AS (
    SELECT
        VendorNumber,
        MAX(VendorName) AS VendorName,
        ROUND(SUM(Dollars), 2) AS TotalPurchaseDollars,
        ROUND(SUM(Quantity), 2) AS TotalPurchaseQuantity
    FROM dbo.clean_purchases
    WHERE Dollars > 0
    GROUP BY VendorNumber
)

SELECT
    COALESCE(vp.VendorNumber, vs.VendorNumber) AS VendorNumber,
    vp.VendorName,

    COALESCE(vs.TotalSalesDollars, 0) AS TotalSalesDollars,
    COALESCE(vp.TotalPurchaseDollars, 0) AS TotalPurchaseDollars,

    COALESCE(vs.TotalSalesQuantity, 0) AS TotalSalesQuantity,
    COALESCE(vp.TotalPurchaseQuantity, 0) AS TotalPurchaseQuantity,

    CAST(
        ROUND(
            COALESCE(vs.TotalSalesDollars, 0)
            / NULLIF(COALESCE(vp.TotalPurchaseDollars, 0), 0),
            2
        ) AS DECIMAL(18,2)
    ) AS SalesToPurchaseValueRatio,

    CAST(
        ROUND(
            CAST(COALESCE(vs.TotalSalesQuantity, 0) AS DECIMAL(18,2))
            / NULLIF(CAST(COALESCE(vp.TotalPurchaseQuantity, 0) AS DECIMAL(18,2)), 0),
            2
        ) AS DECIMAL(18,2)
    ) AS SalesToPurchaseQuantityRatio

FROM VendorPurchases vp
FULL OUTER JOIN VendorSales vs
ON vp.VendorNumber = vs.VendorNumber
ORDER BY TotalSalesDollars DESC;

/*
Vendor-level comparison showed that major vendors generated sales values higher than purchase investment,
with top vendors showing sales-to-purchase ratios between 1.3 and 1.6.
But it is not exact gross profit because it is not calculating sold-unit COGS .
*/

-- ============================================================
-- 20. PRODUCTS PURCHASED BUT NOT SOLD
-- Purpose: Identify products purchased during the year with no matching positive sales
-- ============================================================

WITH ProductSales AS (
    SELECT
        Brand,
        Description,
        Size,
        ROUND(SUM(SalesDollars), 2) AS TotalSalesDollars,
        ROUND(SUM(SalesQuantity), 2) AS TotalSalesQuantity
    FROM dbo.clean_sales
    WHERE SalesDollars > 0
    GROUP BY Brand, Description, Size
),

ProductPurchases AS (
    SELECT
        Brand,
        Description,
        Size,
        ROUND(SUM(Dollars), 2) AS TotalPurchaseDollars,
        ROUND(SUM(Quantity), 2) AS TotalPurchaseQuantity
    FROM dbo.clean_purchases
    WHERE Dollars > 0
    GROUP BY Brand, Description, Size
)

SELECT TOP 30
    pp.Brand,
    pp.Description,
    pp.Size,
    CAST(0 AS DECIMAL(18,2)) AS TotalSalesDollars,
    pp.TotalPurchaseDollars,
    CAST(0 AS DECIMAL(18,2)) AS TotalSalesQuantity,
    pp.TotalPurchaseQuantity,
    CAST(0 AS DECIMAL(18,2)) AS SalesToPurchaseValueRatio,
    CAST(0 AS DECIMAL(18,2)) AS SalesToPurchaseQuantityRatio
FROM ProductPurchases pp
LEFT JOIN ProductSales ps
    ON pp.Brand = ps.Brand
   AND pp.Size = ps.Size
WHERE ps.Brand IS NULL
ORDER BY pp.TotalPurchaseDollars DESC;

/*
These products were purchased but had no positive sales. 
They may be new stock, slow-moving inventory, year-end purchases, or product-size mismatches.
*/


-- ============================================================
-- 21. WEAK-SELLING PURCHASED PRODUCTS
-- Purpose: Identify products that were purchased and sold, but sales are low compared to purchase investment
-- ============================================================

WITH ProductSales AS (
    SELECT
        Brand,
        Description,
        Size,
        ROUND(SUM(SalesDollars), 2) AS TotalSalesDollars,
        ROUND(SUM(SalesQuantity), 2) AS TotalSalesQuantity
    FROM dbo.clean_sales
    WHERE SalesDollars > 0
    GROUP BY Brand, Description, Size
),

ProductPurchases AS (
    SELECT
        Brand,
        Description,
        Size,
        ROUND(SUM(Dollars), 2) AS TotalPurchaseDollars,
        ROUND(SUM(Quantity), 2) AS TotalPurchaseQuantity
    FROM dbo.clean_purchases
    WHERE Dollars > 0
    GROUP BY Brand, Description, Size
)

SELECT TOP 30
    pp.Brand,
    pp.Description,
    pp.Size,
    ps.TotalSalesDollars,
    pp.TotalPurchaseDollars,
    ps.TotalSalesQuantity,
    pp.TotalPurchaseQuantity,

    CAST(
        ROUND(
            ps.TotalSalesDollars / NULLIF(pp.TotalPurchaseDollars, 0),
            2
        ) AS DECIMAL(18,2)
    ) AS SalesToPurchaseValueRatio,

    CAST(
        ROUND(
            CAST(ps.TotalSalesQuantity AS DECIMAL(18,2))
            / NULLIF(CAST(pp.TotalPurchaseQuantity AS DECIMAL(18,2)), 0),
            2
        ) AS DECIMAL(18,2)
    ) AS SalesToPurchaseQuantityRatio

FROM ProductPurchases pp
INNER JOIN ProductSales ps
    ON pp.Brand = ps.Brand
   AND pp.Size = ps.Size
WHERE pp.TotalPurchaseDollars > 0
  AND ps.TotalSalesDollars > 0
  AND ps.TotalSalesDollars / NULLIF(pp.TotalPurchaseDollars, 0) < 0.50
ORDER BY SalesToPurchaseValueRatio ASC, pp.TotalPurchaseDollars DESC;


/*
These products have some sales, but its very weak compared to purchase investment.
Need to be care full next time and note the products
*/

-- ============================================================
-- 22. ZERO-COST PURCHASE ANALYSIS
-- Purpose: Analyze purchase records where quantity exists but purchase cost is zero
-- ============================================================

SELECT
    VendorNumber,
    VendorName,
    Brand,
    Description,
    Size,
    COUNT(*) AS ZeroCostPurchaseRecords,
    ROUND(SUM(Quantity), 2) AS ZeroCostPurchaseQuantity
FROM dbo.clean_purchases
WHERE Quantity > 0
  AND PurchasePrice = 0
  AND Dollars = 0
GROUP BY
    VendorNumber,
    VendorName,
    Brand,
    Description,
    Size
ORDER BY ZeroCostPurchaseQuantity DESC;

/* Result:
VendorNumber	VendorName	       Brand	Description             	Size	      ZeroCostPurchaseRecords	ZeroCostPurchaseQuantity
2561	     EDRINGTON AMERICAS    2166	   The Macallan Double Cask 12	750mL	               153	                      2015
*/


-- ============================================================
-- 23. ZERO-COST PURCHASE IMPACT BY VENDOR
-- Purpose: Identify vendors associated with zero-cost purchase records
-- ============================================================

SELECT
    VendorNumber,
    VendorName,
    COUNT(*) AS ZeroCostRecords,
    ROUND(SUM(Quantity), 2) AS ZeroCostQuantity,
    COUNT(DISTINCT Brand) AS ZeroCostBrands
FROM dbo.clean_purchases
WHERE Quantity > 0
  AND PurchasePrice = 0
  AND Dollars = 0
GROUP BY
    VendorNumber,
    VendorName
ORDER BY ZeroCostQuantity DESC;


/* Result:
VendorNumber	VendorName	            ZeroCostRecords	ZeroCostQuantity	ZeroCostBrands
2561	        EDRINGTON AMERICAS         	153	             2015	             1


Zero-cost purchase records were analyzed separately because they affect inventory quantity but should not be used in purchase cost, 
average cost, or profitability calculations.
*/


--## Purchase and Vendor Analysis Summary

--I found that the business purchased $321.90M of inventory across 80 stores, 126 vendors, 10,663 brands, and 5,543 purchase orders.
--Purchase activity increased from May onward, with the highest monthly purchase spend in July at $33.41M, followed by December at $32.45M.
--This pattern aligns with the sales trend, where demand was also stronger in July and December.

--Vendor purchases were concentrated among a few major suppliers.
--DIAGEO NORTH AMERICA INC was the largest purchase vendor, contributing $50.96M or 15.83% of total purchase spend.
--Other major vendors included MARTIGNETTI COMPANIES, JIM BEAM BRANDS COMPANY, PERNOD RICARD USA, and BACARDI USA INC.

--At the product level, I found that 1.75L products drove the highest purchase value, while 50mL products drove the highest purchase quantity.
--This supports the sales finding that large bottle sizes are key revenue drivers, while mini bottles mainly drive unit volume.

--Freight cost was $1.64M, representing only 0.51% of invoice value.
--Freight percentage was consistent across most vendors, which indicates stable logistics cost behavior.

--Vendor invoices were paid in an average of 35 days, with most invoices falling in the 31-45 day payment bucket.
--Goods were received within an average of 7 days after purchase order creation, indicating an efficient procurement cycle.

--The sales vs purchase comparison showed that major vendors generated higher sales value than purchase investment.
--However, this is not exact gross profit because it compares total sales with total purchases, not sold-unit COGS.
--I flagged zero-cost purchase records separately to preserve inventory quantity accuracy while keeping financial metrics clean.
