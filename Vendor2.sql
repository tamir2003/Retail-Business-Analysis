--------------------------------------------
--          BASIC VENDOR QUERIES
--------------------------------------------

-- 1. Trim Vendor Names
SELECT 
    TRIM(VendorName) AS VendorName
FROM Vendor_sale_summary;


-- 2. Gross Profit Calculation
SELECT 
    VendorName,
    (TotalSalesDollars - TotalPurchaseDollars) AS GrossProfit
FROM Vendor_sale_summary;


-- 3. Profit Margin (%)
SELECT 
    VendorName,
    ((TotalSalesDollars - TotalPurchaseDollars) / TotalSalesDollars) * 100 AS ProfitMargin
FROM Vendor_sale_summary;


-- 4. Stock Turnover Ratio
SELECT 
    VendorName,
    (TotalSalesQuantity / TotalPurchaseQuantity) AS StockTurnOver
FROM Vendor_sale_summary;


-- 5. Sales to Purchase Ratio
SELECT 
    VendorName,
    (TotalSalesDollars / TotalPurchaseDollars) AS SalesToPurchase_Ratio
FROM Vendor_sale_summary;


--------------------------------------------
--     CREATE ENRICHED VENDOR SALES SUMMARY
--------------------------------------------

SELECT 
    *,
    (TotalSalesDollars - TotalPurchaseDollars) AS GrossProfit,
    ((TotalSalesDollars - TotalPurchaseDollars) / TotalSalesDollars) * 100 AS ProfitMargin,
    (TotalSalesQuantity / TotalPurchaseQuantity) AS StockTurnOver,
    (TotalSalesDollars / TotalPurchaseDollars) AS SalesToPurchase_Ratio
INTO VendorSales_summary
FROM Vendor_sale_summary;
