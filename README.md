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

## 🧩 Key SQL Components  

### 🔹 Freight Summary  
```sql
SELECT VendorName, ROUND(SUM(Freight), 2) AS Freight
INTO Freight_Summary
FROM vendor_invoice
GROUP BY VendorName;

# 🌟 Vendor Performance Analysis

Welcome to the **Vendor Performance Analysis** project! 🚀 This SQL-powered solution transforms raw sales, purchase, and freight data into **actionable insights** to boost profitability, optimize inventory, and streamline operations. Dive in to uncover strategies for smarter business decisions! 💡

---

## 🎯 Project Overview

This project harnesses the power of SQL to analyze vendor and brand performance. By leveraging **Common Table Expressions (CTEs)**, it combines datasets to deliver a **unified vendor performance summary** that answers critical business questions. From pricing strategies to inventory optimization, this project is your guide to data-driven success! 📈

---

## 🛠️ Analysis Components

### 📦 1. Freight Summary
- **What it does**: Aggregates freight costs per vendor to spotlight logistics inefficiencies.
- **Output**: A clear view of freight expenses for cost optimization.

### 🛒 2. Purchase Summary
- **What it does**: Summarizes total purchases, quantities, and unit costs by vendor and brand.
- **Output**: Insights for cost analysis and supplier negotiations.

### 💸 3. Sales Summary
- **What it does**: Calculates total sales quantity, sales dollars, and average price per vendor.
- **Output**: Key metrics to evaluate revenue and sales performance.

### 📊 4. Vendor Summary (CTE Approach)
- **What it does**: Combines purchase, sales, and freight data using CTEs for a holistic view.
- **Output**:
  - `Vendor_sale_summary`: Initial vendor performance overview.
  - `VendorSales_summary`: Final enriched table packed with KPIs.

---

## ❓ Business Questions & Insights

> ### 🔹 Q1. Which brands need promotional or pricing adjustments?
> - **Insight**: Brands with low sales but high profit margins suggest pricing is too steep.
> - **Action**: Launch promotions or discounts to drive sales. 🎉

> ### 🔹 Q2. Which vendors and brands shine in sales performance?
> - **Insight**: Top vendors deliver high `TotalSalesDollars` and `GrossProfit`.
> - **Action**: Replicate their effective sales and inventory strategies. 🌟

> ### 🔹 Q3. Which vendors drive the most purchase dollars?
> - **Insight**: High-value vendors dominate total purchases.
> - **Action**: Negotiate bulk discounts and strengthen supplier ties. 🤝

> ### 🔹 Q4. Does bulk purchasing reduce unit costs?
> - **Insight**: Yes! Bulk orders achieve unit prices as low as **$10.78**, ~72% cheaper than smaller orders.
> - **Action**: Prioritize bulk buying for better margins. 💰

> ### 🔹 Q5. Which vendors have slow-moving stock?
> - **Insight**: Vendors with `StockTurnOver < 1` hold excess inventory with low sales velocity.
> - **Action**: Optimize inventory and deploy clearance strategies. 📉

> ### 🔹 Q6. How much capital is tied up in unsold inventory?
> - **Insight**: High purchase-low sales vendors lock up working capital.
> - **Action**: Improve capital efficiency and cut storage costs. 🔄

---

## 📊 Statistical Highlights

| **Metric**            | **Observation**                                                                 |
|-----------------------|--------------------------------------------------------------------------------|
| **Gross Profit**      | Minimum of **-52,002.78**, signaling losses in some transactions.               |
| **Profit Margin (%)** | Negative/infinite values due to loss-making or zero sales.                     |
| **Sales Quantity & Dollars** | Zero sales for some products indicate obsolete/unsold stock.              |
| **Freight Cost**      | Ranges from **0.09 to 257,032.07**, hinting at logistics inefficiencies.       |
| **Stock Turnover**    | Varies from **0 to 274.5**, showing uneven sales velocity.                     |

---

## 📚 Key Metrics Calculated

| **Metric**                  | **Description**                                      | **Formula**                                                                 |
|-----------------------------|-----------------------------------------------------|-----------------------------------------------------------------------------|
| **Gross Profit**            | Profit after subtracting purchase costs              | `TotalSalesDollars - TotalPurchaseDollars`                                  |
| **Profit Margin (%)**       | Measures profitability as a percentage               | `((TotalSalesDollars - TotalPurchaseDollars) / TotalSalesDollars) * 100`   |
| **Stock Turnover**          | Evaluates sales efficiency vs. inventory             | `TotalSalesQuantity / TotalPurchaseQuantity`                                |
| **Sales to Purchase Ratio** | Revenue generated per purchase dollar                | `TotalSalesDollars / TotalPurchaseDollars`                                  |

---

## 🚀 Results

- ✅ **Delivered**: `VendorSales_Summary` table with all key KPIs.
- 📊 **Insights**: Actionable metrics on vendor profitability, pricing, and inventory.
- 💡 **Opportunities**: Identified cost-saving and performance-boosting strategies.

---

## 💼 How to Get Started

1. **Import Scripts** 📥
   - Load all `.sql` scripts into **SQL Server** or **PostgreSQL**.

2. **Run Queries in Order** ▶️
   - `Freight_Summary`
   - `Purchase_Summary`
   - `Sales_Summary`
   - `Vendor_sale_summary`
   - `VendorSales_summary` (final enriched output)

3. **Visualize & Analyze** 📈
   - Import results into **Power BI** or **Excel** for stunning visualizations and trend analysis.

---

## 🏁 Conclusion

This project showcases SQL’s power to go beyond data retrieval, delivering **transformative business insights**. By integrating sales, purchase, and freight data, it fuels:

- 🧭 **Strategic Decisions**: Smarter pricing and promotional strategies.
- 💵 **Profitability Growth**: Identification of top-performing vendors and brands.
- ⚙️ **Operational Excellence**: Optimized inventory and logistics.

---

