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
