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

# Vendor Performance Analysis

This project leverages SQL to analyze vendor performance by integrating sales, purchase, and freight data. It generates actionable insights into profitability, pricing strategies, inventory management, and operational efficiency.

## 📋 Project Overview

The project processes raw datasets to produce summarized tables and key performance indicators (KPIs) for vendor and brand performance. Using Common Table Expressions (CTEs), it combines data to create a unified vendor performance summary, answering critical business questions.

---

## 📊 Analysis Components

### 1. Freight Summary
- **Purpose**: Aggregates freight cost data per vendor.
- **Output**: Summarized freight costs to identify logistics inefficiencies.

### 2. Purchase Summary
- **Purpose**: Summarizes total purchases, quantities, and unit costs per vendor and brand.
- **Output**: Detailed purchase insights for cost analysis and supplier negotiations.

### 3. Sales Summary
- **Purpose**: Computes total sales quantity, sales dollars, and average price per vendor.
- **Output**: Sales performance metrics to evaluate revenue generation.

### 4. Vendor Summary (CTE Approach)
- **Purpose**: Combines purchase, sales, and freight data using CTEs for a holistic view.
- **Output**:
  - `Vendor_sale_summary`: Initial vendor performance summary.
  - `VendorSales_summary`: Final enriched table with all KPIs.

---

## 🔍 Business Questions & Insights

### Q1. Which brands need promotional or pricing adjustments?
- **Insight**: Brands with low sales volume but high profit margins indicate pricing may be too high.
- **Action**: Implement promotions or discounts to boost sales.

### Q2. Which vendors and brands demonstrate the highest sales performance?
- **Insight**: Top vendors generate high `TotalSalesDollars` and `GrossProfit`.
- **Action**: Leverage effective sales and inventory management strategies from these vendors.

### Q3. Which vendors contribute the most to total purchase dollars?
- **Insight**: High-value vendors account for the majority of purchases.
- **Action**: Negotiate bulk discounts and strengthen supplier relationships.

### Q4. Does purchasing in bulk reduce unit cost?
- **Insight**: Yes, bulk purchases achieve unit prices as low as $10.78, ~72% cheaper than smaller orders.
- **Action**: Prioritize bulk purchasing to improve profit margins.

### Q5. Which vendors have low inventory turnover (slow-moving stock)?
- **Insight**: Vendors with `StockTurnOver < 1` have excess inventory and poor sales velocity.
- **Action**: Optimize inventory and implement clearance strategies.

### Q6. How much capital is locked in unsold inventory?
- **Insight**: Vendors with high purchases but low sales tie up working capital.
- **Action**: Enhance capital efficiency and reduce storage costs.

---

## 📈 Statistical Summary Highlights

| **Metric**            | **Observation**                                                                 |
|-----------------------|--------------------------------------------------------------------------------|
| **Gross Profit**      | Minimum value of -52,002.78, indicating losses in some transactions.            |
| **Profit Margin (%)** | Includes negative/infinite values due to loss-making or zero sales.             |
| **Sales Quantity & Dollars** | Some products show 0 sales, indicating obsolete or unsold stock.           |
| **Freight Cost**      | Ranges from 0.09 to 257,032.07, suggesting possible logistics inefficiencies.   |
| **Stock Turnover**    | Ranges from 0 to 274.5, reflecting uneven sales velocity.                       |

---

## 📚 Key Metrics Calculated

| **Metric**                  | **Description**                                      | **Formula**                                                                 |
|-----------------------------|-----------------------------------------------------|-----------------------------------------------------------------------------|
| **Gross Profit**            | Profit after deducting purchase cost                 | `TotalSalesDollars - TotalPurchaseDollars`                                  |
| **Profit Margin (%)**       | Profitability ratio                                  | `((TotalSalesDollars - TotalPurchaseDollars) / TotalSalesDollars) * 100`   |
| **Stock Turnover**          | Sales efficiency vs. inventory                       | `TotalSalesQuantity / TotalPurchaseQuantity`                                |
| **Sales to Purchase Ratio** | Revenue per purchase dollar                         | `TotalSalesDollars / TotalPurchaseDollars`                                  |

---

## 🚀 Results

- ✅ Created `VendorSales_Summary` table with all key KPIs.
- 📊 Delivered actionable insights into vendor profitability, pricing, and inventory.
- 💡 Identified cost reduction opportunities and sales performance improvements.

---

## 💼 How to Use

1. **Import SQL Scripts**:
   - Import all provided `.sql` scripts into **SQL Server** or **PostgreSQL**.

2. **Run Queries Sequentially**:
   - `Freight_Summary`
   - `Purchase_Summary`
   - `Sales_Summary`
   - `Vendor_sale_summary`
   - `VendorSales_summary` (final analytical summary)

3. **Visualize Results**:
   - Load the results into **Power BI** or **Excel** for visualization and trend analysis.

---

## 🏁 Conclusion

This project showcases the power of SQL for data analysis, transforming raw data into actionable business insights. By integrating sales, purchase, and freight data, it drives:

- 🧭 **Business Strategy**: Informed decision-making for pricing and promotions.
- 💵 **Profitability Analysis**: Identification of high-performing vendors and brands.
- ⚙️ **Operational Efficiency**: Optimization of inventory and logistics.

---

