USE RetailVendorInventoryDB;
GO

-- ============================================================
-- 1. DIM VENDOR
-- Purpose: Create one clean vendor name per vendor number
-- ============================================================

CREATE OR ALTER VIEW dbo.dim_vendor AS
WITH VendorNames AS (
    SELECT 
        VendorNo AS VendorNumber,
        VendorName
    FROM dbo.clean_sales

    UNION ALL

    SELECT 
        VendorNumber,
        VendorName
    FROM dbo.clean_purchases

    UNION ALL

    SELECT 
        VendorNumber,
        VendorName
    FROM dbo.clean_vendor_invoice

    UNION ALL

    SELECT 
        VendorNumber,
        VendorName
    FROM dbo.clean_purchase_prices
),

VendorNameRank AS (
    SELECT
        VendorNumber,
        VendorName,
        COUNT(*) AS NameFrequency,
        ROW_NUMBER() OVER (
            PARTITION BY VendorNumber
            ORDER BY COUNT(*) DESC, VendorName
        ) AS rn
    FROM VendorNames
    WHERE VendorNumber IS NOT NULL
    GROUP BY VendorNumber, VendorName
)

SELECT
    VendorNumber,
    VendorName AS CleanVendorName
FROM VendorNameRank
WHERE rn = 1;
GO


-- ============================================================
-- 2. DIM PRODUCT
-- Purpose: Create product dimension using Brand + Size as product key
-- ============================================================

CREATE OR ALTER VIEW dbo.dim_product AS
WITH ProductData AS (
    SELECT 
        Brand,
        Description,
        Size,
        Classification,
        Volume
    FROM dbo.clean_sales

    UNION ALL

    SELECT
        Brand,
        Description,
        Size,
        Classification,
        NULL AS Volume
    FROM dbo.clean_purchases

    UNION ALL

    SELECT
        Brand,
        Description,
        Size,
        Classification,
        Volume
    FROM dbo.clean_purchase_prices

    UNION ALL

    SELECT
        Brand,
        Description,
        Size,
        NULL AS Classification,
        NULL AS Volume
    FROM dbo.clean_end_inventory
)

SELECT
    CONCAT(Brand, '|', Size) AS ProductKey,
    Brand,
    MAX(Description) AS ProductName,
    Size,
    MAX(Classification) AS Classification,
    MAX(Volume) AS Volume
FROM ProductData
WHERE Brand IS NOT NULL
GROUP BY Brand, Size;
GO


-- ============================================================
-- 3. DIM STORE
-- Purpose: Create store dimension with city mapping
-- ============================================================

CREATE OR ALTER VIEW dbo.dim_store AS
WITH StoreData AS (
    SELECT Store, City FROM dbo.clean_begin_inventory
    UNION ALL
    SELECT Store, City FROM dbo.clean_end_inventory
)

SELECT
    Store,
    MAX(City) AS City
FROM StoreData
WHERE Store IS NOT NULL
GROUP BY Store;
GO



-- ============================================================
-- 4. FACT SALES
-- Purpose: Final sales fact view for Power BI
-- ============================================================

CREATE OR ALTER VIEW dbo.fact_sales AS
SELECT
    InventoryId,
    Store,
    CONCAT(Brand, '|', Size) AS ProductKey,
    Brand,
    Size,
    VendorNo AS VendorNumber,
    SalesDate,
    SalesQuantity,
    SalesDollars,
    SalesPrice,
    ExciseTax,

    CASE 
        WHEN SalesQuantity > 0 AND SalesDollars = 0 AND SalesPrice = 0
            THEN 'Zero Value Sale'
        WHEN SalesQuantity <= 0 OR SalesDollars < 0 OR SalesPrice < 0
            THEN 'Invalid Sale'
        ELSE 'Valid Sale'
    END AS SalesDataQualityFlag,

    CASE
        WHEN SalesDollars > 0 THEN 1
        ELSE 0
    END AS IsFinancialSale

FROM dbo.clean_sales;
GO



-- ============================================================
-- 5. FACT PURCHASES
-- Purpose: Final purchase fact view for Power BI
-- ============================================================

CREATE OR ALTER VIEW dbo.fact_purchases AS
SELECT
    InventoryId,
    Store,
    CONCAT(Brand, '|', Size) AS ProductKey,
    Brand,
    Size,
    VendorNumber,

    PONumber,
    PODate,
    ReceivingDate,
    InvoiceDate,
    PayDate,
    PurchasePrice,
    Quantity AS PurchaseQuantity,
    Dollars AS PurchaseDollars,

    DATEDIFF(DAY, PODate, ReceivingDate) AS DaysToReceive,

    CASE 
        WHEN Quantity > 0 AND PurchasePrice = 0 AND Dollars = 0
            THEN 'Zero Cost Purchase'
        WHEN Quantity <= 0 OR Dollars < 0 OR PurchasePrice < 0
            THEN 'Invalid Purchase'
        ELSE 'Valid Purchase'
    END AS PurchaseDataQualityFlag,

    CASE
        WHEN Dollars > 0 THEN 1
        ELSE 0
    END AS IsFinancialPurchase

FROM dbo.clean_purchases;
GO


-- ============================================================
-- 6. FACT VENDOR INVOICE
-- Purpose: Final vendor invoice and freight view for Power BI
-- ============================================================

CREATE OR ALTER VIEW dbo.fact_vendor_invoice AS
SELECT
    VendorNumber,
    PONumber,
    InvoiceDate,
    PayDate,
    Quantity AS InvoiceQuantity,
    Dollars AS InvoiceDollars,
    Freight,

    DATEDIFF(DAY, InvoiceDate, PayDate) AS PaymentDays,

    ROUND(Freight / NULLIF(Dollars, 0) * 100, 2) AS FreightPct

FROM dbo.clean_vendor_invoice
WHERE Dollars > 0;
GO


-- ============================================================
-- 7. INVENTORY MOVEMENT
-- Purpose: Reconcile beginning stock, purchases, sales, and ending stock
-- ============================================================

CREATE OR ALTER VIEW dbo.fact_inventory_movement AS
WITH BeginInv AS (
    SELECT
        InventoryId,
        Store,
        Brand,
        MAX(Description) AS Description,
        MAX(Size) AS Size,
        SUM(onHand) AS BeginningQty,
        SUM(BeginningInventoryValue) AS BeginningInventoryValue
    FROM dbo.clean_begin_inventory
    GROUP BY InventoryId, Store, Brand
),
EndInv AS (
    SELECT
        InventoryId,
        Store,
        Brand,
        MAX(Description) AS Description,
        MAX(Size) AS Size,
        SUM(onHand) AS EndingQty,
        SUM(EndingInventoryValue) AS EndingInventoryValue
    FROM dbo.clean_end_inventory
    GROUP BY InventoryId, Store, Brand
),

PurchaseQty AS (
    SELECT
        InventoryId,
        Store,
        Brand,
        MAX(Description) AS Description,
        MAX(Size) AS Size,
        SUM(Quantity) AS PurchasedQty
    FROM dbo.clean_purchases
    GROUP BY InventoryId, Store, Brand
),

SalesQty AS (
    SELECT
        InventoryId,
        Store,
        Brand,
        MAX(Description) AS Description,
        MAX(Size) AS Size,
        SUM(SalesQuantity) AS SoldQty
    FROM dbo.clean_sales
    GROUP BY InventoryId, Store, Brand
),

InventoryKeys AS (
    SELECT InventoryId, Store, Brand FROM BeginInv
    UNION
    SELECT InventoryId, Store, Brand FROM EndInv
    UNION
    SELECT InventoryId, Store, Brand FROM PurchaseQty
    UNION
    SELECT InventoryId, Store, Brand FROM SalesQty
)

SELECT
    k.InventoryId,
    k.Store,
    CONCAT(k.Brand, '|', COALESCE(e.Size, b.Size, p.Size, s.Size)) AS ProductKey,
    k.Brand,
    COALESCE(e.Description, b.Description, p.Description, s.Description, 'Unknown') AS Description,
    COALESCE(e.Size, b.Size, p.Size, s.Size) AS Size,

    COALESCE(b.BeginningQty, 0) AS BeginningQty,
    COALESCE(p.PurchasedQty, 0) AS PurchasedQty,
    COALESCE(s.SoldQty, 0) AS SoldQty,
    COALESCE(e.EndingQty, 0) AS ActualEndingQty,

    COALESCE(b.BeginningQty, 0) + COALESCE(p.PurchasedQty, 0) - COALESCE(s.SoldQty, 0) AS ExpectedEndingQty,

    COALESCE(e.EndingQty, 0) - (COALESCE(b.BeginningQty, 0) + COALESCE(p.PurchasedQty, 0) - COALESCE(s.SoldQty, 0)) AS StockVarianceQty,

    COALESCE(b.BeginningInventoryValue, 0) AS BeginningInventoryValue,
    COALESCE(e.EndingInventoryValue, 0) AS EndingInventoryValue,

    CAST(
        ROUND(
            CAST(COALESCE(s.SoldQty, 0) AS DECIMAL(18,2))
            / NULLIF(
                CAST(COALESCE(b.BeginningQty, 0) + COALESCE(p.PurchasedQty, 0) AS DECIMAL(18,2)),
                0
            ),
            2
        ) AS DECIMAL(18,2)
    ) AS SellThroughRatio

FROM InventoryKeys k
LEFT JOIN BeginInv b
    ON k.InventoryId = b.InventoryId
LEFT JOIN EndInv e
    ON k.InventoryId = e.InventoryId
LEFT JOIN PurchaseQty p
    ON k.InventoryId = p.InventoryId
LEFT JOIN SalesQty s
    ON k.InventoryId = s.InventoryId;
GO


-- ============================================================
-- 8. SALES ABC PRODUCT VIEW
-- Purpose: Classify products by revenue contribution
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_sales_product_abc AS
WITH ProductSales AS (
    SELECT
        CONCAT(Brand, '|', Size) AS ProductKey,
        Brand,
        Description,
        Size,
        ROUND(SUM(SalesDollars), 2) AS TotalSalesDollars
    FROM dbo.clean_sales
    WHERE SalesDollars > 0
    GROUP BY Brand, Description, Size
),

ProductContribution AS (
    SELECT
        ProductKey,
        Brand,
        Description,
        Size,
        TotalSalesDollars,
        ROUND(
            SUM(TotalSalesDollars) OVER (
                ORDER BY TotalSalesDollars DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )
            / NULLIF(SUM(TotalSalesDollars) OVER (), 0) * 100,
            2
        ) AS CumulativeSalesPct
    FROM ProductSales
)

SELECT
    ProductKey,
    Brand,
    Description,
    Size,
    TotalSalesDollars,
    CumulativeSalesPct,
    CASE
        WHEN CumulativeSalesPct <= 70 THEN 'A - Core Revenue Product'
        WHEN CumulativeSalesPct <= 90 THEN 'B - Mid Revenue Product'
        ELSE 'C - Long Tail Product'
    END AS SalesABCClass
FROM ProductContribution;
GO


-- ============================================================
-- 9. INVENTORY ABC PRODUCT VIEW
-- Purpose: Classify products by ending inventory value
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_inventory_product_abc AS
WITH ProductInventory AS (
    SELECT
        CONCAT(Brand, '|', Size) AS ProductKey,
        Brand,
        Description,
        Size,
        ROUND(SUM(EndingInventoryValue), 2) AS EndingInventoryValue
    FROM dbo.clean_end_inventory
    GROUP BY Brand, Description, Size
),

InventoryContribution AS (
    SELECT
        ProductKey,
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
    ProductKey,
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
FROM InventoryContribution;
GO

