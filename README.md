📊 Vendor Sales & Purchase Data Analysis using SQL
🧾 Project Overview

This project focuses on analyzing vendor performance, purchase behavior, sales trends, and profitability using SQL.
The goal is to transform raw transactional data into meaningful business insights that can help in strategic decision-making — such as identifying top-performing vendors, optimizing pricing, and reducing inventory costs.

🧠 Objective

To perform an end-to-end data analysis on vendor, purchase, and sales data, answering key business questions such as:

Which vendors and brands drive the highest sales and profits?

Which vendors are overstocked or have slow-moving inventory?

Does bulk purchasing result in cost savings?

How efficiently is capital being utilized in purchases and sales?

🗂️ Data Sources

The project uses the following relational tables:

purchases – Purchase transactions by vendor, brand, and quantity

purchase_prices – Purchase price details per brand and vendor

sales – Sales quantity, price, and excise details

vendor_invoice – Freight and logistics cost information

⚙️ Technologies Used

SQL Server / T-SQL

Microsoft Excel / Power BI (for summary statistics & visualization)

*Data Cleaning, Aggregation & Analysis using SQL CTEs and Summary Tables

🧩 Key SQL Components

The analysis was performed in multiple stages:

Freight Summary

SELECT VendorName, ROUND(SUM(Freight), 2) AS Freight
INTO Freight_Summary
FROM vendor_invoice
GROUP BY VendorName;


Purchase Summary
Summarized total purchases, quantities, and unit costs per vendor and brand.

Sales Summary
Computed total sales quantity, dollars, and price per vendor.

Vendor Summary (CTE Approach)
Combined purchase, sales, and freight data using CTEs to create a unified vendor performance summary:

Vendor_sale_summary

VendorSales_summary (final enriched version)

📈 Business Questions & Insights
Q1. Which brands need promotional or pricing adjustments?

Brands with low sales volume but high profit margins were identified.
➡️ Indicates that pricing may be too high — promotions or discounts could improve sales.

Q2. Which vendors and brands demonstrate the highest sales performance?

Top vendors generated the maximum TotalSalesDollars and high GrossProfit — indicating effective sales and inventory management.

Q3. Which vendors contribute the most to total purchase dollars?

Identified high-value vendors who account for a large share of total purchases.
➡️ Useful for negotiating bulk discounts and improving supplier relationships.

Q4. Does purchasing in bulk reduce unit cost?

✅ Yes.
Vendors buying in bulk (large order sizes) get unit prices as low as $10.78, nearly 72% cheaper than smaller orders.
➡️ Indicates effective bulk pricing strategies leading to higher margins.

Q5. Which vendors have low inventory turnover (slow-moving stock)?

Low StockTurnOver (<1) vendors were identified, indicating excess inventory and poor sales velocity.
➡️ These vendors need inventory optimization and clearance strategies.

Q6. How much capital is locked in unsold inventory per vendor?

Vendors with high purchase dollars but low sales are tying up capital in unsold goods.
➡️ Critical for improving working capital efficiency and reducing storage costs.

📊 Statistical Summary Highlights

Gross Profit: Minimum value of -52,002.78, indicating losses in some transactions.

Profit Margin: Includes negative and infinite values due to zero or loss-making sales.

Sales Quantity & Dollars: Some products show 0 sales — representing obsolete or unsold stock.

Freight Cost: Ranges from 0.09 to 257,032.07, showing potential logistics inefficiencies.

Stock Turnover: Ranges from 0 to 274.5, suggesting uneven sales velocity across vendors.

📚 Key Metrics Calculated
Metric	Description	Formula
Gross Profit	Profit earned after deducting purchase cost	TotalSalesDollars - TotalPurchaseDollars
Profit Margin (%)	Profitability ratio	((TotalSalesDollars - TotalPurchaseDollars) / TotalSalesDollars) * 100
Stock Turnover	Sales efficiency vs inventory	TotalSalesQuantity / TotalPurchaseQuantity
Sales to Purchase Ratio	Revenue per purchase dollar	TotalSalesDollars / TotalPurchaseDollars
🚀 Results

Created a VendorSales_Summary table with all key KPIs.

Delivered actionable insights into vendor profitability, pricing strategies, and inventory management.

Identified opportunities for cost reduction and improved sales performance.

💼 How to Use

Import all provided .sql scripts into your SQL Server or PostgreSQL environment.

Run queries sequentially to generate summary tables (Freight_Summary, Purchase_Summary, Sales_Summary, Vendor_sale_summary).

Finally, execute the VendorSales_summary script to create the complete analytical summary.

Use Power BI or Excel to visualize KPIs and trends.

🏁 Conclusion

This project showcases how SQL can be used not only for data retrieval but also for analytical insights.
By combining sales, purchase, and freight data, we’ve derived meaningful metrics to guide business strategy, profitability analysis, and operational efficiency.
