USE RetailVendorInventoryDB;
GO

-- ============================================================
-- 1. OVERALL INVENTORY KPIs
-- Purpose: Compare opening and closing inventory value
-- ============================================================

SELECT
    ROUND(SUM(onHand), 2) AS BeginningStockQuantity,
    ROUND(SUM(BeginningInventoryValue), 2) AS BeginningInventoryValue,
    COUNT(DISTINCT Store) AS TotalStores,
    COUNT(DISTINCT Brand) AS TotalBrands,
    COUNT(DISTINCT InventoryId) AS TotalInventoryItems
FROM dbo.clean_begin_inventory;

SELECT
    ROUND(SUM(onHand), 2) AS EndingStockQuantity,
    ROUND(SUM(EndingInventoryValue), 2) AS EndingInventoryValue,
    COUNT(DISTINCT Store) AS TotalStores,
    COUNT(DISTINCT Brand) AS TotalBrands,
    COUNT(DISTINCT InventoryId) AS TotalInventoryItems
FROM dbo.clean_end_inventory;


-- ============================================================
-- 2. OPENING VS CLOSING INVENTORY SUMMARY
-- Purpose: Compare beginning and ending inventory at total level
-- ============================================================

WITH BeginInv AS (
    SELECT
        SUM(onHand) AS BeginningQty,
        SUM(BeginningInventoryValue) AS BeginningValue
    FROM dbo.clean_begin_inventory
),

EndInv AS (
    SELECT
        SUM(onHand) AS EndingQty,
        SUM(EndingInventoryValue) AS EndingValue
    FROM dbo.clean_end_inventory
)

SELECT
    ROUND(b.BeginningQty, 2) AS BeginningStockQuantity,
    ROUND(e.EndingQty, 2) AS EndingStockQuantity,
    ROUND(e.EndingQty - b.BeginningQty, 2) AS StockQuantityChange,

    ROUND(b.BeginningValue, 2) AS BeginningInventoryValue,
    ROUND(e.EndingValue, 2) AS EndingInventoryValue,
    ROUND(e.EndingValue - b.BeginningValue, 2) AS InventoryValueChange,

    ROUND(
        (e.EndingValue - b.BeginningValue) / NULLIF(b.BeginningValue, 0) * 100,
        2
    ) AS InventoryValueChangePct
FROM BeginInv b
CROSS JOIN EndInv e;


/*
Inventory value increased from $68.05M to $79.70M, representing a 17.12% increase in closing stock value.
This suggests higher year-end inventory holding and potential working capital impact.
*/



-- ============================================================
-- 3. ENDING INVENTORY BY STORE
-- Purpose: Identify stores holding the highest closing stock value
-- ============================================================

SELECT TOP 10
    Store,
    City,
    ROUND(SUM(onHand), 2) AS EndingStockQuantity,
    ROUND(SUM(EndingInventoryValue), 2) AS EndingInventoryValue,
    COUNT(DISTINCT Brand) AS TotalBrands,
    COUNT(DISTINCT InventoryId) AS TotalInventoryItems
FROM dbo.clean_end_inventory
GROUP BY Store, City
ORDER BY EndingInventoryValue DESC;


-- ============================================================
-- 4. ENDING INVENTORY BY CITY
-- Purpose: Analyze inventory value by location/city
-- ============================================================

SELECT TOP 10
    City,
    ROUND(SUM(onHand), 2) AS EndingStockQuantity,
    ROUND(SUM(EndingInventoryValue), 2) AS EndingInventoryValue,
    COUNT(DISTINCT Store) AS TotalStores,
    COUNT(DISTINCT Brand) AS TotalBrands
FROM dbo.clean_end_inventory
GROUP BY City
ORDER BY EndingInventoryValue DESC;

/*
Store 50 in Mountmend held the highest ending inventory value at $4.89M. 
At the city level,Mountmend had the largest closing inventory value of $9.71M.
*/


-- ============================================================
-- 5. TOP PRODUCTS BY ENDING INVENTORY VALUE
-- Purpose: Identify products with highest unsold capital
-- ============================================================

SELECT TOP 20
    Brand,
    Description,
    Size,
    ROUND(SUM(onHand), 2) AS EndingStockQuantity,
    ROUND(SUM(EndingInventoryValue), 2) AS EndingInventoryValue,
    COUNT(DISTINCT Store) AS StoresHoldingStock
FROM dbo.clean_end_inventory
GROUP BY Brand, Description, Size
ORDER BY EndingInventoryValue DESC;

/*
Top ending inventory value products include:
Jack Daniels No 7 Black 1.75L
Ketel One Vodka 1.75L
Johnnie Walker Black Label 1.75L
Absolut 80 Proof 1.75L
Tito's Handmade Vodka 1.75L
Capt Morgan Spiced Rum 1.75L

High-value ending inventory was concentrated in large 1.75L liquor products, which were also major sales and purchase drivers. 
These products should be prioritized for stock monitoring because they represent high inventory value.
*/

-- ============================================================
-- 6. TOP PRODUCTS BY ENDING STOCK QUANTITY
-- Purpose: Identify products with highest remaining unit stock
-- ============================================================

SELECT TOP 20
    Brand,
    Description,
    Size,
    ROUND(SUM(onHand), 2) AS EndingStockQuantity,
    ROUND(SUM(EndingInventoryValue), 2) AS EndingInventoryValue,
    COUNT(DISTINCT Store) AS StoresHoldingStock
FROM dbo.clean_end_inventory
GROUP BY Brand, Description, Size
ORDER BY EndingStockQuantity DESC;

/*
Inventory quantity and inventory value showed different product patterns.
Smaller 50mL products had high unit stock, while larger 1.75L products carried higher inventory value.
1.75L products = high inventory value
50mL products = high inventory quantity
*/


-- ============================================================
-- 7. PRODUCT-STORE RECORDS IN BEGINNING INVENTORY BUT NOT ENDING INVENTORY
-- Purpose: Identify products that existed at start but not at year end
-- ============================================================

SELECT TOP 30
    b.InventoryId,
    b.Store,
    b.City,
    b.Brand,
    b.Description,
    b.Size,
    ROUND(b.onHand, 2) AS BeginningStockQuantity,
    ROUND(b.BeginningInventoryValue, 2) AS BeginningInventoryValue
FROM dbo.clean_begin_inventory b
LEFT JOIN dbo.clean_end_inventory e
    ON b.InventoryId = e.InventoryId
WHERE e.InventoryId IS NULL
ORDER BY b.BeginningInventoryValue DESC;

/*
Insight:
I found that some product-store inventory records were available in beginning inventory but were not present in ending inventory.
The highest-value missing beginning inventory item was Ch Haut Brion 10 at Store 69 in Mountmend, with a beginning inventory value of $15.60K.
This may indicate that these products were sold out, discontinued, transferred, or not restocked at the same store by year-end.

Business Takeaway:
These products should be reviewed to understand whether the stock movement was due to successful sell-through or inventory discontinuation.
High-value premium products missing from ending inventory are important to track because they can affect product availability, replenishment planning, and premium-category sales opportunities.
*/


-- ============================================================
-- 8. PRODUCT-STORE RECORDS IN ENDING INVENTORY BUT NOT BEGINNING INVENTORY
-- Purpose: Identify new products/stock added during the year
-- ============================================================

SELECT TOP 30
    e.InventoryId,
    e.Store,
    e.City,
    e.Brand,
    e.Description,
    e.Size,
    ROUND(e.onHand, 2) AS EndingStockQuantity,
    ROUND(e.EndingInventoryValue, 2) AS EndingInventoryValue
FROM dbo.clean_end_inventory e
LEFT JOIN dbo.clean_begin_inventory b
    ON e.InventoryId = b.InventoryId
WHERE b.InventoryId IS NULL
ORDER BY e.EndingInventoryValue DESC;

/*
Insight:
I found that several product-store inventory records were newly added during the year, meaning they were present in ending inventory but not in beginning inventory.
The highest-value new ending inventory item was Integre Vodka at Store 50 in Mountmend, with an ending inventory value of $22.02K.
Store 50 in Mountmend appears multiple times in the top new inventory list,suggesting that this location received a significant amount of new or restocked inventory during the year.

Business Takeaway:
The business should monitor newly added high-value inventory to ensure it converts into sales and does not become slow-moving stock.
Stores with large new inventory additions, especially Mountmend, should be reviewed for demand alignment, replenishment strategy, and inventory turnover performance.


Overall Finding:
By comparing beginning and ending inventory, I found that some product-store combinations were removed from inventory during the year, while new product-store combinations were added by year-end.
Beginning-only inventory mainly highlights products that may have sold out, been discontinued, or not restocked at the same store.
Ending-only inventory highlights newly introduced or newly stocked products that require sales and turnover monitoring.
This comparison helps identify product movement, new stock additions, and possible inventory replacement patterns.
*/

-- ============================================================
-- 9. OVERALL INVENTORY MOVEMENT VALIDATION
-- Purpose: Validate total stock movement at overall business level
-- Formula: Expected Ending Stock = Beginning Stock + Purchased Quantity - Sold Quantity
-- ============================================================

WITH BeginInv AS (
    SELECT SUM(onHand) AS BeginningQty
    FROM dbo.clean_begin_inventory
),

PurchaseQty AS (
    SELECT SUM(Quantity) AS PurchasedQty
    FROM dbo.clean_purchases
),

SalesQty AS (
    SELECT SUM(SalesQuantity) AS SoldQty
    FROM dbo.clean_sales
),

EndInv AS (
    SELECT SUM(onHand) AS ActualEndingQty
    FROM dbo.clean_end_inventory
)

SELECT
    ROUND(b.BeginningQty, 2) AS BeginningQty,
    ROUND(p.PurchasedQty, 2) AS PurchasedQty,
    ROUND(s.SoldQty, 2) AS SoldQty,
    ROUND(e.ActualEndingQty, 2) AS ActualEndingQty,

    ROUND(b.BeginningQty + p.PurchasedQty - s.SoldQty, 2) AS ExpectedEndingQty,

    ROUND(
        e.ActualEndingQty - (b.BeginningQty + p.PurchasedQty - s.SoldQty),
        2
    ) AS StockVarianceQty
FROM BeginInv b
CROSS JOIN PurchaseQty p
CROSS JOIN SalesQty s
CROSS JOIN EndInv e;


--Insight:
-- Overall inventory reconciliation matched exactly.
-- Beginning Stock + Purchased Quantity - Sold Quantity = Actual Ending Stock.
-- Stock variance is 0, confirming that sales, purchases, and inventory  are internally consistent.


-- ============================================================
-- 10. SLOW-MOVING PRODUCTS WITH ENDING STOCK
-- Purpose: Identify products with low sell-through and remaining inventory value
-- ============================================================

WITH BeginInv AS (
    SELECT
        Brand,
        MAX(Description) AS Description,
        Size,
        SUM(onHand) AS BeginningQty,
        SUM(BeginningInventoryValue) AS BeginningInventoryValue
    FROM dbo.clean_begin_inventory
    GROUP BY  Brand, Description , Size
),

PurchaseQty AS (
    SELECT
       
        Brand,
        MAX(Description) AS Description,
        Size,
        SUM(Quantity) AS PurchasedQty
    FROM dbo.clean_purchases
    GROUP BY Brand, Description , Size
),

SalesQty AS (
    SELECT
        
        Brand,
        MAX(Description) AS Description,
        Size,
        SUM(SalesQuantity) AS SoldQty
    FROM dbo.clean_sales
    GROUP BY Brand, Description , Size
),
EndInv AS (
    SELECT
        
        Brand,
        MAX(Description) AS Description,
        Size,
        SUM(onHand) AS EndingQty,
        SUM(EndingInventoryValue) AS EndingInventoryValue
    FROM dbo.clean_end_inventory
    GROUP BY Brand, Description , Size
)
SELECT TOP 10
    e.Brand,
    e.Description,
    e.Size,
    COALESCE(b.BeginningQty, 0) AS BeginningQty,
    COALESCE(p.PurchasedQty, 0) AS PurchasedQty,
    COALESCE(s.SoldQty, 0) AS SoldQty,
    e.EndingQty,
    ROUND(e.EndingInventoryValue, 2) AS EndingInventoryValue
FROM EndInv e
LEFT JOIN BeginInv b
    ON e.Brand = b.Brand and e.Description = b.Description and e.Size = b.Size 
LEFT JOIN PurchaseQty p
    ON e.Brand = p.Brand and e.Description = p.Description and e.Size = p.Size 
LEFT JOIN SalesQty s
   ON e.Brand = s.Brand and e.Description = s.Description and e.Size = s.Size 
ORDER BY e.EndingInventoryValue DESC;

/* Aggregation is done at brand ,Description and Size Level because same products are available in different brand and Size*/


-- ============================================================
-- 11. HIGH-VALUE UNSOLD INVENTORY
-- Purpose: Identify products where business capital is blocked in ending inventory
-- ============================================================

SELECT TOP 30
    Brand,
    Description,
    Size,
    ROUND(SUM(onHand), 2) AS EndingStockQuantity,
    ROUND(SUM(EndingInventoryValue), 2) AS EndingInventoryValue,
    COUNT(DISTINCT Store) AS StoresHoldingStock
FROM dbo.clean_end_inventory
WHERE onHand > 0
GROUP BY Brand, Description, Size
ORDER BY EndingInventoryValue DESC;


-- ============================================================
-- 12. ABC ANALYSIS - ENDING INVENTORY VALUE
-- Purpose: Classify products based on closing inventory value contribution
-- A = Products contributing up to 70% of inventory value
-- B = Next products contributing up to 90%
-- C = Remaining long-tail products
-- ============================================================

WITH ProductInventory AS (
    SELECT
        Brand,
        Description,
        Size,
        ROUND(SUM(EndingInventoryValue), 2) AS EndingInventoryValue
    FROM dbo.clean_end_inventory
    GROUP BY Brand, Description, Size
),

InventoryContribution AS (
    SELECT
        Brand,
        Description,
        Size,
        EndingInventoryValue,

        ROUND(
            SUM(EndingInventoryValue) OVER (
                ORDER BY EndingInventoryValue DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )
            / NULLIF(SUM(EndingInventoryValue) OVER (), 0) * 100,
            2
        ) AS CumulativeInventoryPct
    FROM ProductInventory
)

SELECT
    Brand,
    Description,
    Size,
    EndingInventoryValue,
    CumulativeInventoryPct,

    CASE
        WHEN CumulativeInventoryPct <= 70 THEN 'A - High Inventory Value'
        WHEN CumulativeInventoryPct <= 90 THEN 'B - Medium Inventory Value'
        ELSE 'C - Low Inventory Value'
    END AS InventoryABCClass

FROM InventoryContribution
ORDER BY EndingInventoryValue DESC;

/*
Out of approximately 9.6K products, the first 1.5K products fall under Class A, 
the next group up to around 3.4K products falls under Class B, and the remaining products fall under Class C.
*/


/*## Inventory Analysis Summary

I found that beginning inventory was 4.22M units valued at $68.05M, while ending inventory increased to 4.89M units valued at $79.70M.
This represents an increase of 666.5K units and $11.65M in inventory value, or 17.12%.

At the store level, Store 50 in Mountmend held the highest ending inventory value at $4.89M.
At the city level, Mountmend had the highest total ending inventory value of $9.71M.

Product-level inventory analysis showed that high-value ending inventory was concentrated in major 1.75L liquor products such as Jack Daniels No 7 Black, Ketel One Vodka, Johnnie Walker Black Label, Absolut 80 Proof, and Tito's Handmade Vodka.
Smaller 50mL products appeared more frequently in high-quantity stock rankings but contributed lower inventory value.

Inventory movement validation matched exactly.
Beginning stock of 4.22M units plus 33.58M purchased units minus 32.92M sold units resulted in expected ending stock of 4.89M units, which matched the actual ending inventory.
This produced zero stock variance, confirming that sales, purchases, and inventory snapshots are internally consistent.

ABC inventory analysis helped me identify the smaller group of products that contributed most of the ending inventory value, while the remaining products formed a long-tail inventory segment.
*/
