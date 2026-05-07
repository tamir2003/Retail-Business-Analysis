# Retail Business Analysis

## Project Overview

This project is an end-to-end **Retail Sales, Purchase, Vendor & Inventory Analytics** solution built using **Python, SQL Server, and Power BI**.

The project analyzes retail business performance across sales, purchases, vendors, freight cost, payment cycles, and inventory movement. The goal is to identify revenue drivers, vendor dependency, purchase behavior, stock movement accuracy, and inventory holding patterns to support data-driven business decisions.

---

## Business Objective

The main objective of this project is to answer key business questions:

- How much revenue did the business generate?
- Which stores, vendors, products, and product sizes drive sales?
- Which vendors receive the highest purchase investment?
- How much freight cost is incurred and how significant is it?
- How long does it take to receive stock and pay vendor invoices?
- Which products hold the highest inventory value?
- Is inventory movement internally consistent?
- Are beginning inventory, purchases, sales, and ending inventory properly reconciled?

---

## Tools & Technologies Used

| Tool | Purpose |
|---|---|
| **Python** | Data cleaning, data validation, preprocessing |
| **Pandas** | Data transformation and missing value handling |
| **SQL Server** | Data quality checks, business analysis, views |
| **T-SQL** | CTEs, window functions, aggregations, ranking, ABC analysis |
| **Power BI** | Data modeling, DAX measures, dashboard development |
| **DAX** | KPI calculations, ratios, time-based measures |
| **Excel/CSV** | Source data files |

---

## Dataset Description

The project uses six retail datasets:

| Table | Description |
|---|---|
| **Sales** | Product-level sales transactions across stores |
| **Purchases** | Product purchase records from vendors |
| **Purchase Prices** | Product price and vendor reference data |
| **Vendor Invoice** | Vendor invoice, freight, and payment details |
| **Beginning Inventory** | Opening inventory snapshot at the start of the year |
| **Ending Inventory** | Closing inventory snapshot at the end of the year |

---

## Key Business Metrics

| Metric | Value |
|---|---:|
| **Total Sales** | **$452.06M** |
| **Total Purchase** | **$321.90M** |
| **Estimated Sales-Purchase Gap** | **$130.16M** |
| **Estimated Gap %** | **28.79%** |
| **Total Freight Cost** | **$1.64M** |
| **Freight %** | **0.51%** |
| **Beginning Inventory Value** | **$68.05M** |
| **Ending Inventory Value** | **$79.70M** |
| **Inventory Value Change** | **17.12%** |
| **Beginning Stock Quantity** | **4.22M units** |
| **Purchased Quantity** | **33.58M units** |
| **Sold Quantity** | **32.92M units** |
| **Ending Stock Quantity** | **4.89M units** |
| **Stock Variance** | **0** |
| **Stores** | **80** |
| **Vendors** | **127+** |
| **Products** | **11K+** |

> **Note:** The sales-purchase gap is an estimated high-level margin indicator calculated as total sales minus total purchases. It is not a true COGS-based gross profit calculation.

---

## Project Workflow

### 1. Data Cleaning using Python

Python was used to clean and prepare the raw datasets before loading them into SQL Server.

Key cleaning steps included:

- Loaded six raw retail datasets.
- Standardized column names.
- Trimmed extra spaces from text fields such as vendor names.
- Converted date columns into proper datetime format.
- Converted numeric fields such as sales, purchase, quantity, price, freight, and tax values.
- Handled missing values in product size, volume, description, and city columns.
- Created inventory value columns:
  - `BeginningInventoryValue = onHand × Price`
  - `EndingInventoryValue = onHand × Price`
- Exported cleaned datasets for SQL analysis.

---

### 2. SQL Data Quality Checks

After loading cleaned data into SQL Server, data quality checks were performed to validate the datasets.

Checks included:

- Row count validation.
- Date range validation.
- Null value checks.
- Duplicate checks.
- Sales amount validation: `SalesDollars = SalesQuantity × SalesPrice`.
- Purchase amount validation: `Dollars = Quantity × PurchasePrice`.
- Invalid and zero-value transaction checks.
- Vendor name consistency checks.
- Brand-size consistency checks.
- Inventory value validation.

Important findings:

- 55 zero-value sales records were found.
- 153 zero-cost purchase records were found.
- Some vendor numbers had multiple vendor name variations.
- Some brands had multiple package-size formats.
- Inventory value calculations were validated successfully.

Zero-value and zero-cost quantity records were not deleted because they still affect inventory movement.

---

### 3. SQL Sales Analysis

Sales analysis was performed to identify revenue drivers and sales patterns.

Analysis included:

- Overall sales KPIs.
- Monthly sales trend.
- Month-over-month sales growth.
- Top stores by sales.
- Top vendors by sales.
- Top products by sales.
- Top products by quantity sold.
- Sales by product size.
- Sales by classification.
- Product revenue contribution.
- ABC product segmentation.
- Zero-value sales analysis.

Key insights:

- Total sales reached **$452.06M**.
- December was the highest sales month with **$52.31M**.
- July showed a strong peak with **$49.7M** in sales.
- August saw a decline of around **21.4%** after the July peak.
- Store 76 was the highest-performing store with around **$25.4M** in sales.
- 1.75L products drove high revenue.
- 50mL products drove high unit quantity.
- 750mL products contributed the highest sales by size.
- Top vendors such as DIAGEO, Martignetti, Pernod Ricard, Jim Beam, and Bacardi drove major revenue contribution.

---

### 4. SQL Purchase & Vendor Analysis

Purchase and vendor analysis was performed to understand purchase investment, vendor dependency, freight cost, and payment behavior.

Analysis included:

- Overall purchase KPIs.
- Monthly purchase trend.
- Month-over-month purchase growth.
- Top vendors by purchase spend.
- Vendor purchase contribution.
- Top products by purchase value.
- Top products by purchase quantity.
- Purchase by store.
- Purchase by classification.
- Freight cost analysis.
- Freight percentage analysis.
- Payment cycle analysis.
- PO-to-receiving cycle analysis.
- Vendor-level sales vs purchase comparison.
- Product-level sales vs purchase comparison.
- Zero-cost purchase analysis.

Key insights:

- Total purchase value was **$321.90M**.
- DIAGEO NORTH AMERICA INC was the top purchase vendor.
- The top 5 vendors contributed approximately **45%** of total purchase spend.
- Total freight cost was **$1.64M**, representing only **0.51%** of invoice value.
- Average payment cycle was around **35.5 days**.
- Average stock receiving time was around **7.6 days** after purchase order creation.
- Major vendors generated sales value higher than purchase investment.

---

### 5. SQL Inventory Analysis

Inventory analysis was performed to evaluate opening stock, closing stock, unsold inventory value, stock movement, and reconciliation.

Analysis included:

- Overall inventory KPIs.
- Opening vs closing inventory comparison.
- Ending inventory by city and store.
- Top products by ending inventory value.
- Top products by ending stock quantity.
- Products in beginning inventory but not ending inventory.
- Products in ending inventory but not beginning inventory.
- Inventory movement reconciliation.
- Sell-through ratio.
- Slow-moving inventory analysis.
- High-value unsold inventory analysis.
- ABC inventory classification.

Inventory reconciliation formula:

```text
Expected Ending Stock = Beginning Stock + Purchased Quantity - Sold Quantity
```

Result:

```text
4.22M + 33.58M - 32.92M = 4.89M
```

Actual ending stock:

```text
4.89M
```

Stock variance:

```text
0
```

Key insight:

Inventory movement matched perfectly across all store-product records, confirming that sales, purchases, and inventory snapshots were internally consistent.

---

## Power BI Data Model

A star schema model was created in Power BI.

### Dimension Tables

| Dimension | Description |
|---|---|
| **Date Table** | Continuous calendar table created in Power BI |
| **dim_product** | Product details with ABC classification |
| **dim_vendor** | Clean vendor names by vendor number |
| **dim_store** | Store and city details |

### Fact Tables

| Fact Table | Description |
|---|---|
| **fact_sales** | Sales transactions |
| **fact_purchases** | Purchase records |
| **fact_vendor_invoice** | Invoice, freight, and payment details |
| **fact_inventory_movement** | Beginning, purchase, sales, ending, and stock variance data |

ABC classes were added to `dim_product` using `LOOKUPVALUE()` for a cleaner model and easier filtering.

---

## Power BI Dashboard Pages

The dashboard contains four main report pages:

### 1. Executive Overview

Includes:

- Total Sales
- Total Purchase
- Estimated Sales-Purchase Gap
- Estimated Gap %
- Ending Inventory Value
- Stock Variance Quantity
- Monthly Sales Trend
- Month-over-Month Sales Growth
- Sales vs Purchase Trend
- Top Stores by Sales
- Top Vendors by Sales
- Sales by Classification

### 2. Sales Performance Analysis

Includes:

- Total Sales
- Total Sales Quantity
- Average Selling Price
- Total Excise Tax
- Sales by Product Size
- Product ABC Class Contribution
- Monthly Sales Trend
- Top Sold Products
- Product Sales Details
- Sales by Vendor

### 3. Vendor & Purchase Analysis

Includes:

- Total Purchase
- Average Purchase Price
- Total Freight
- Average Payment Days
- Vendor Sales vs Purchase Pattern
- Vendors by Freight Cost
- Vendors by Purchase Spend
- Vendor-level summary table
- Freight %
- Sales-to-Purchase Ratio

### 4. Inventory Analysis

Includes:

- Beginning Inventory Value
- Ending Inventory Value
- Inventory Value Change %
- Stock Variance Quantity
- Sell-Through Ratio
- Ending Inventory by City
- Top Products by Ending Inventory Value
- Inventory ABC Class Analysis
- Inventory Movement Table

---

## Important DAX Measures

Some of the key DAX measures used:

```DAX
Total Sales =
CALCULATE(
    SUM(fact_sales[SalesDollars]),
    fact_sales[IsFinancialSale] = 1
)
```

```DAX
Total Purchase =
CALCULATE(
    SUM(fact_purchases[PurchaseDollars]),
    fact_purchases[IsFinancialPurchase] = 1
)
```

```DAX
Total Freight =
SUM(fact_vendor_invoice[Freight])
```

```DAX
Freight % =
DIVIDE(
    [Total Freight],
    [Total Invoice Dollars]
)
```

```DAX
Sell Through Ratio =
DIVIDE(
    [Sold Quantity],
    [Beginning Quantity] + [Purchased Quantity]
)
```

```DAX
Stock Variance Quantity =
SUM(fact_inventory_movement[StockVarianceQty])
```

```DAX
Inventory Value Change % =
DIVIDE(
    [Ending Inventory Value] - [Beginning Inventory Value],
    [Beginning Inventory Value]
)
```

---

## Key Insights

### Sales Insights

- Total sales were **$452.06M**.
- December was the highest sales month.
- July showed a strong seasonal sales peak.
- August declined by around **21.4%** after the July peak.
- Store 76 was the top-performing store.
- Top vendors drove a large share of sales.
- 1.75L products were major revenue drivers.
- 50mL products were major quantity drivers.

### Purchase & Vendor Insights

- Total purchases were **$321.90M**.
- Top vendors showed strong concentration in purchase spend.
- Freight cost was low at only **0.51%** of invoice value.
- Average vendor payment time was around **35.5 days**.
- Average stock receiving time was around **7.6 days**.
- Top vendors generated sales value higher than purchase investment.

### Inventory Insights

- Beginning inventory value was **$68.05M**.
- Ending inventory value increased to **$79.70M**.
- Inventory value increased by **17.12%**.
- Sell-through ratio was approximately **87%**.
- Inventory reconciliation showed **zero stock variance**.
- High-value ending inventory was concentrated in large bottle-size products.
- Mountmend was the top city by ending inventory value.

---

## Business Recommendations

Based on the analysis:

- Monitor high-value inventory products closely to avoid overstocking.
- Review slow-moving premium inventory for markdowns, promotions, or vendor return discussions.
- Maintain strong relationships with top vendors while reducing over-dependency risk.
- Use seasonal sales patterns to plan inventory before peak months such as July and December.
- Investigate low-performing stores and compare their product mix with top-performing stores.
- Track freight percentage regularly, even though current freight cost impact is low.
- Use ABC classification to prioritize high-impact revenue and inventory products.

---

## Project Outcome

This project demonstrates the ability to:

- Clean and validate large multi-source datasets.
- Build SQL-based analytical layers.
- Perform sales, purchase, vendor, freight, and inventory analysis.
- Reconcile inventory movement across multiple business tables.
- Create a star schema Power BI model.
- Build DAX measures for business KPIs.
- Design an interactive dashboard for business decision-making.

---

## Skills Demonstrated

- Data Cleaning
- Data Validation
- SQL Analysis
- T-SQL CTEs
- Window Functions
- Joins
- Aggregations
- ABC Analysis
- Vendor Analysis
- Inventory Reconciliation
- Power BI Data Modeling
- Star Schema Design
- DAX Measures
- KPI Reporting
- Dashboard Development
- Business Insight Generation

---

## Dashboard Preview
<img width="1366" height="674" alt="Screenshot (362)" src="https://github.com/user-attachments/assets/80e04c15-6d09-4b15-a1a6-9f8f9c6e889a" />


<img width="1362" height="669" alt="Screenshot (363)" src="https://github.com/user-attachments/assets/8212b465-8190-4663-8110-528dbca4eaf9" />


<img width="1366" height="674" alt="Screenshot (364)" src="https://github.com/user-attachments/assets/07acea7b-047b-43bf-ab9d-de396ee1a819" />


<img width="1345" height="690" alt="Screenshot (365)" src="https://github.com/user-attachments/assets/db312506-f898-4b36-9630-49cdf7a497ac" />



<img width="1362" height="674" alt="Screenshot (367)" src="https://github.com/user-attachments/assets/e2220793-7f38-4825-b3d1-26ae6710c2bc" />


