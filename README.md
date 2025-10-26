# 📊 Vendor Sales & Purchase Data Analysis using SQL

## 🧾 Project Overview  
This project focuses on **analyzing vendor performance, purchase behavior, sales trends, and profitability** using **SQL**.  
The goal is to transform raw transactional data into **meaningful business insights** that support **strategic decision-making** — such as identifying top-performing vendors, optimizing pricing, and reducing inventory costs.

---

## 🧠 Objective  
Perform an **end-to-end data analysis** on vendor, purchase, and sales data to answer key business questions:

- 🏆 Which vendors and brands drive the highest sales and profits?  
- 🏬 Which vendors are overstocked or have slow-moving inventory?  
- 💰 Does bulk purchasing result in cost savings?  
- ⚙️ How efficiently is capital being utilized in purchases and sales?

---

## 🗂️ Data Sources  
This project is built using four key relational tables:

| Table Name | Description |
|-------------|-------------|
| **purchases** | Purchase transactions by vendor, brand, and quantity |
| **purchase_prices** | Purchase price details per brand and vendor |
| **sales** | Sales quantity, price, and excise details |
| **vendor_invoice** | Freight and logistics cost information |

---

## ⚙️ Technologies Used  
- 🧠 **SQL Server / T-SQL**  
- 📊 **Microsoft Excel / Power BI** – for summary statistics & data visualization  
- 🧩 **Data Cleaning, Aggregation & Analysis** using SQL CTEs and Summary Tables  

---

## 📈 Business Questions & Insights
**Q1. Which brands need promotional or pricing adjustments?**

Brands with low sales volume but high profit margins were identified.
➡️ Indicates that pricing may be too high — promotions or discounts could improve sales.

**Q2. Which vendors and brands demonstrate the highest sales performance?**

Top vendors generated the maximum TotalSalesDollars and high GrossProfit — indicating effective sales and inventory management.

**Q3. Which vendors contribute the most to total purchase dollars?**

Identified high-value vendors who account for a large share of total purchases.
➡️ Useful for negotiating bulk discounts and improving supplier relationships.

**Q4. Does purchasing in bulk reduce unit cost?**

**✅ Yes!**
Vendors buying in bulk (large order sizes) get unit prices as low as $10.78, nearly 72% cheaper than smaller orders.
➡️ Effective bulk pricing strategies lead to higher margins and stronger vendor partnerships.

**Q5. Which vendors have low inventory turnover (slow-moving stock)?**

Vendors with StockTurnOver < 1 indicate excess inventory and poor sales velocity.
➡️ Need inventory optimization and clearance strategies.

**Q6. How much capital is locked in unsold inventory per vendor?**

Vendors with high purchase dollars but low sales are tying up capital in unsold goods.
➡️ Reducing this improves working capital efficiency and lowers storage costs.

## 📊 Statistical Summary Highlights
- Metric	Observation
- Gross Profit	Minimum value of -52,002.78, indicating losses on some transactions.
- Profit Margin	Includes negative and infinite values due to zero or loss-making sales.
- Sales Quantity & Dollars	Some products have 0 sales, representing obsolete or unsold stock.
- Freight Cost	Ranges from 0.09 to 257,032.07, showing logistics inefficiencies or bulk shipments.
- Stock Turnover	Ranges from 0 to 274.5, implying varied sales velocity across vendors.

## 📚 Key Metrics Calculated
-  Metric	Description	Formula
-  Gross Profit	Profit earned after deducting purchase cost	TotalSalesDollars - TotalPurchaseDollars
-  Profit Margin (%)	Profitability ratio	((TotalSalesDollars - TotalPurchaseDollars) / TotalSalesDollars) * 100
-  Stock Turnover	Sales efficiency vs inventory	TotalSalesQuantity / TotalPurchaseQuantity
-  Sales to Purchase Ratio	Revenue per purchase dollar	TotalSalesDollars / TotalPurchaseDollars

## 🚀 Results

- **✅ Created a VendorSales_Summary table with all key KPIs.**
- **✅ Delivered actionable insights into vendor profitability, pricing strategies, and inventory management.**
- **✅ Identified opportunities for cost reduction, higher sales efficiency, and inventory optimization.**
