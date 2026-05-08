USE RetailVendorInventoryDB;
GO

-- ============================================================
-- 1. ROW COUNT CHECK
-- Purpose: Verify that all cleaned datasets are loaded properly
-- ============================================================

SELECT 'Sales' AS TableName, COUNT(*) AS TotalRows FROM dbo.clean_sales
UNION ALL
SELECT 'Purchases', COUNT(*) FROM dbo.clean_purchases
UNION ALL
SELECT 'Purchase Prices', COUNT(*) FROM dbo.clean_purchase_prices
UNION ALL
SELECT 'Vendor Invoice', COUNT(*) FROM dbo.clean_vendor_invoice
UNION ALL
SELECT 'Begin Inventory', COUNT(*) FROM dbo.clean_begin_inventory
UNION ALL
SELECT 'End Inventory', COUNT(*) FROM dbo.clean_end_inventory;


-- ============================================================
-- 2. DATE RANGE CHECK
-- Purpose: Understand the available time period in each table
-- ============================================================


SELECT 
    MIN(SalesDate) AS MinSalesDate,
    MAX(SalesDate) AS MaxSalesDate
FROM dbo.clean_sales;

SELECT 
    MIN(ReceivingDate) AS MinReceivingDate,
    MAX(ReceivingDate) AS MaxReceivingDate
FROM dbo.clean_purchases;

SELECT 
    MIN(InvoiceDate) AS MinInvoiceDate,
    MAX(InvoiceDate) AS MaxInvoiceDate
FROM dbo.clean_vendor_invoice;

SELECT 
    MIN(startDate) AS BeginInventoryDate,
    MAX(startDate) AS MaxBeginInventoryDate
FROM dbo.clean_begin_inventory;

SELECT 
    MIN(endDate) AS EndInventoryDate,
    MAX(endDate) AS MaxEndInventoryDate
FROM dbo.clean_end_inventory;


-- clean_begin_inventory contains opening stock as of 2024-01-01.
-- clean_end_inventory contains closing stock as of 2024-12-31.
-- Therefore, only one date is expected in each inventory table.

-- ============================================================
-- 3. BUSINESS ENTITY COUNT CHECK
-- Purpose: Understand number of stores, brands, vendors, products
-- ============================================================


SELECT
    COUNT(DISTINCT Store) AS TotalStores,
    COUNT(DISTINCT Brand) AS TotalBrands,
    COUNT(DISTINCT VendorNo) AS TotalVendors,
    COUNT(DISTINCT InventoryId) AS TotalInventoryItems
FROM dbo.clean_sales;


SELECT
    COUNT(DISTINCT Store) AS TotalStores,
    COUNT(DISTINCT Brand) AS TotalBrands,
    COUNT(DISTINCT VendorNumber) AS TotalVendors,
    COUNT(DISTINCT PONumber) AS TotalPurchaseOrders
FROM dbo.clean_purchases;

/* The sales and purchase datasets cover the same 80 stores, confirming consistency at the store level.
Sales data contains 11,237 brands, while purchase data contains 10,664 brands. 
This difference indicates that some products were sold from existing inventory or prior-year stock without new purchases during the analysis period. 
Sales also includes one additional vendor compared to purchases, likely due to products sold from opening inventory.
*/


---- Brands purchased but not sold

SELECT 
    COUNT(DISTINCT p.Brand) AS BrandsPurchasedButNotSold
FROM dbo.clean_purchases p
LEFT JOIN dbo.clean_sales s
    ON p.Brand = s.Brand
WHERE s.Brand IS NULL;

----Vendors in purchases but not sales

SELECT DISTINCT
    p.VendorNumber,
    p.VendorName
FROM dbo.clean_purchases p
LEFT JOIN dbo.clean_sales s
    ON p.VendorNumber = s.VendorNo
WHERE s.VendorNo IS NULL
ORDER BY p.VendorName;

-- ============================================================
-- 4. SALES AMOUNT VALIDATION
-- Purpose: Check whether SalesDollars = SalesQuantity * SalesPrice
-- ============================================================

SELECT 
    COUNT(*) AS SalesAmountMismatchRows
FROM dbo.clean_sales
WHERE ABS(SalesDollars - ROUND(SalesQuantity * SalesPrice, 2)) > 0.05;

-- zero mismatch

-- ============================================================
-- 5. PURCHASE AMOUNT VALIDATION
-- Purpose: Check whether Dollars = Quantity * PurchasePrice
-- ============================================================

SELECT 
    COUNT(*) AS PurchaseAmountMismatchRows
FROM dbo.clean_purchases
WHERE ABS(Dollars - ROUND(Quantity * PurchasePrice, 2)) > 0.05;

-- zero mismatch

-- ============================================================
-- 6. NEGATIVE OR ZERO VALUE CHECK
-- Purpose: Identify invalid or unusual numeric values
-- ============================================================

SELECT 
    COUNT(*) AS InvalidSalesRows
FROM dbo.clean_sales
WHERE SalesQuantity <= 0
   OR SalesDollars < 0
   OR SalesPrice <= 0;

SELECT 
    COUNT(*) AS InvalidPurchaseRows
FROM dbo.clean_purchases
WHERE Quantity <= 0
   OR Dollars < 0
   OR PurchasePrice <= 0;

SELECT 
    COUNT(*) AS InvalidInvoiceRows
FROM dbo.clean_vendor_invoice
WHERE Quantity <= 0
   OR Dollars < 0
   OR Freight < 0;

SELECT 
    COUNT(*) AS InvalidEndingInventoryRows
FROM dbo.clean_end_inventory
WHERE onHand < 0
   OR Price < 0
   OR EndingInventoryValue < 0;

SELECT 
    COUNT(*) AS InvalidBeginningInventoryRows
FROM dbo.clean_begin_inventory
WHERE onHand < 0
   OR Price < 0
   OR BeginningInventoryValue < 0;


create  view dbo.Sales_zero_values as
SELECT * 
FROM dbo.clean_sales
WHERE SalesQuantity <= 0
   OR SalesDollars < 0
   OR SalesPrice <= 0;

create view dbo.purchases_zero_values as 
SELECT * 
FROM dbo.clean_purchases
WHERE Quantity <= 0
   OR Dollars < 0
   OR PurchasePrice <= 0;


/* During data quality validation, 55 sales rows and 153 purchase rows were identified as zero-value transactions. These records had positive quantities but zero sales price or purchase price. 
   Since these rows may represent free items, promotional transactions, stock adjustments, or zero-cost receipts, they were not deleted.
   Instead, they were created as view separately so that quantity-based inventory analysis remains accurate while financial metrics such as average price, cost, and profit can exclude zero-value records where required.
 */



-- ============================================================
-- 7. VENDOR CONSISTENCY CHECK
-- Purpose: Check whether one VendorNumber maps to multiple VendorNames
-- ============================================================

SELECT 
    VendorNo,
    COUNT(DISTINCT VendorName) AS VendorNameCount
FROM dbo.clean_sales
GROUP BY VendorNo
HAVING COUNT(DISTINCT VendorName) > 1;


SELECT 
    VendorNumber,
    COUNT(DISTINCT VendorName) AS VendorNameCount
FROM dbo.clean_purchases
GROUP BY VendorNumber
HAVING COUNT(DISTINCT VendorName) > 1;

SELECT 
    VendorNumber,
    COUNT(DISTINCT VendorName) AS VendorNameCount
FROM dbo.clean_vendor_invoice
GROUP BY VendorNumber
HAVING COUNT(DISTINCT VendorName) > 1;

SELECT 
    VendorNumber,
    COUNT(DISTINCT VendorName) AS VendorNameCount
FROM dbo.clean_purchase_prices
GROUP BY VendorNumber
HAVING COUNT(DISTINCT VendorName) > 1;

--Result:

--SOUTHERN GLAZERS W&S OF NE  2000
--SOUTHERN WINE & SPIRITS NE  2000

--VINEYARD BRANDS INC  1587       
--VINEYARD BRANDS LLC  1587  

UPDATE dbo.clean_sales
SET VendorName = 'SOUTHERN GLAZERS W&S OF NE'
WHERE VendorNo = 2000;

UPDATE dbo.clean_purchases
SET VendorName = 'SOUTHERN GLAZERS W&S OF NE'
WHERE VendorNumber = 2000;

UPDATE dbo.clean_vendor_invoice
SET VendorName = 'SOUTHERN GLAZERS W&S OF NE'
WHERE VendorNumber = 2000;

UPDATE dbo.clean_sales
SET VendorName = 'VINEYARD BRANDS LLC'
WHERE VendorNo = 1587;

UPDATE dbo.clean_purchases
SET VendorName = 'VINEYARD BRANDS LLC'
WHERE VendorNumber = 1587;

UPDATE dbo.clean_vendor_invoice
SET VendorName = 'VINEYARD BRANDS LLC'
WHERE VendorNumber = 1587;

/*Vendor name consistency checks showed that some vendor numbers were associated with multiple vendor name variations(old name and new name)
  Since VendorNumber and VendorName is the reliable unique identifier, standardize vendor names and avoid duplicate vendor grouping in analysis.*/


-- ============================================================
-- 8. BRAND / PRODUCT CONSISTENCY CHECK
-- Purpose: Check whether one Brand has multiple descriptions or sizes
-- ============================================================

SELECT 
    Brand,
    COUNT(DISTINCT Description) AS DescriptionCount,
    COUNT(DISTINCT Size) AS SizeCount
FROM dbo.clean_sales
GROUP BY Brand
HAVING COUNT(DISTINCT Description) > 1
    OR COUNT(DISTINCT Size) > 1;

/*
Brand consistency checks showed that a few Brand IDs were associated with multiple package sizes while keeping the same product description. 
These were treated as valid product-size variations rather than data errors.
For accurate analysis, product-level joins were handled using Brand and Size instead of Brand alone.*/


-- ============================================================
-- 9. INVENTORY VALUE VALIDATION
-- Purpose: Validate calculated inventory value columns
-- ============================================================

SELECT 
    COUNT(*) AS BeginningInventoryValueMismatchRows
FROM dbo.clean_begin_inventory
WHERE ABS(BeginningInventoryValue - ROUND(onHand * Price, 2)) > 0.05;

--Zero Mismaatch

SELECT 
    COUNT(*) AS EndingInventoryValueMismatchRows
FROM dbo.clean_end_inventory
WHERE ABS(EndingInventoryValue - ROUND(onHand * Price, 2)) > 0.05;

--Zero Mismatch
