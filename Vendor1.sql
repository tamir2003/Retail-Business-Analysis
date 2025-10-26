--------------------------------------------
--              FREIGHT SUMMARY
--------------------------------------------
SELECT 
    VendorName,
    ROUND(SUM(Freight), 2) AS Freight
INTO Freight_Summary
FROM dbo.vendor_invoice
GROUP BY VendorName;


--------------------------------------------
--             PURCHASE SUMMARY
--------------------------------------------
SELECT 
    p.Brand,
    p.VendorNumber,
    p.VendorName,
    pp.Volume,
    p.PurchasePrice,
    pp.Price AS Actual_Price,
    p.Description,
    SUM(p.Quantity) AS Total_PurchaseQuantity,
    ROUND(SUM(p.Dollars), 2) AS Total_PurchaseAmount
INTO purchase_summary
FROM dbo.purchases AS p
JOIN dbo.purchase_prices AS pp
    ON p.Brand = pp.Brand
WHERE p.PurchasePrice > 0
GROUP BY 
    p.VendorNumber,
    p.VendorName,
    p.Brand,
    pp.Price,
    pp.Volume,
    p.PurchasePrice,
    p.Description
ORDER BY Total_PurchaseQuantity;


--------------------------------------------
--               SALES SUMMARY
--------------------------------------------
SELECT  
    VendorName,
    VendorNo,
    ROUND(SUM(SalesQuantity), 2) AS Total_PurchaseQuantity,
    ROUND(SUM(SalesDollars), 2)  AS Total_PurchaseAmount,
    ROUND(SUM(SalesPrice), 2)    AS Total_SalePrice
INTO Vendor_sales_summary
FROM dbo.sales
GROUP BY VendorName, VendorNo
ORDER BY Total_PurchaseQuantity DESC;


--------------------------------------------
--         CREATE VENDOR SUMMARY TABLE
--------------------------------------------
SELECT
    pp.VendorName,
    pp.VendorNumber,
    pp.Price AS ActualPrice,
    pp.PurchasePrice,
    ROUND(SUM(CAST(s.SalesQuantity AS DECIMAL(18, 2))), 2) AS TotalSalesQuantity,
    ROUND(SUM(CAST(s.SalesPrice AS DECIMAL(18, 2))), 2)    AS TotalSalesPrice,
    ROUND(SUM(CAST(s.SalesDollars AS DECIMAL(18, 2))), 2)  AS TotalSalesDollars,
    ROUND(SUM(CAST(s.ExciseTax AS DECIMAL(18, 2))), 2)     AS TotalSalesExiceTax,
    ROUND(SUM(CAST(vi.Quantity AS DECIMAL(18, 2))), 2)     AS TotalPurchaseQuantity,
    ROUND(SUM(CAST(vi.Dollars AS DECIMAL(18, 2))), 2)      AS TotalPurchaseDollars,
    ROUND(SUM(CAST(vi.Freight AS DECIMAL(18, 2))), 2)      AS TotalFreightCost
INTO VendorSummary
FROM purchase_prices AS pp
JOIN sales AS s
    ON pp.VendorNumber = s.VendorNo 
   AND pp.Brand = s.Brand
JOIN vendor_invoice AS vi
    ON pp.VendorNumber = vi.VendorNumber
GROUP BY 
    pp.VendorName,
    pp.VendorNumber,
    pp.Price,
    pp.PurchasePrice;


--------------------------------------------
--   ALTERNATIVE METHOD USING CTEs
--------------------------------------------
WITH FreightSummary AS (
    SELECT 
        VendorNumber, 
        ROUND(SUM(Freight), 2) AS FreightCost 
    FROM vendor_invoice 
    GROUP BY VendorNumber
), 

PurchaseSummary AS (
    SELECT 
        p.VendorNumber,
        p.VendorName,
        p.Brand,
        p.Description,
        p.PurchasePrice,
        pp.Price AS ActualPrice,
        pp.Volume,
        ROUND(SUM(p.Quantity), 2) AS TotalPurchaseQuantity,
        ROUND(SUM(p.Dollars), 2)  AS TotalPurchaseDollars
    FROM purchases AS p
    JOIN purchase_prices AS pp
        ON p.Brand = pp.Brand
    WHERE p.PurchasePrice > 0
    GROUP BY 
        p.VendorNumber,
        p.VendorName,
        p.Brand,
        p.Description,
        p.PurchasePrice,
        pp.Price,
        pp.Volume
), 

SalesSummary AS (
    SELECT 
        VendorNo,
        Brand,
        ROUND(SUM(SalesQuantity), 2) AS TotalSalesQuantity,
        ROUND(SUM(SalesDollars), 2)  AS TotalSalesDollars,
        ROUND(SUM(SalesPrice), 2)    AS TotalSalesPrice,
        ROUND(SUM(ExciseTax), 2)     AS TotalExciseTax
    FROM sales
    GROUP BY VendorNo, Brand
)

SELECT 
    ps.VendorNumber,
    ps.VendorName,
    ps.Brand,
    ps.Description,
    ps.PurchasePrice,
    ps.ActualPrice,
    ps.Volume,
    ps.TotalPurchaseQuantity,
    ps.TotalPurchaseDollars,
    ss.TotalSalesQuantity,
    ss.TotalSalesDollars,
    ss.TotalSalesPrice,
    ss.TotalExciseTax,
    fs.FreightCost
INTO Vendor_sale_summary
FROM PurchaseSummary AS ps
LEFT JOIN SalesSummary AS ss 
    ON ps.VendorNumber = ss.VendorNo 
   AND ps.Brand = ss.Brand
LEFT JOIN FreightSummary AS fs 
    ON ps.VendorNumber = fs.VendorNumber
ORDER BY ps.TotalPurchaseDollars DESC;
