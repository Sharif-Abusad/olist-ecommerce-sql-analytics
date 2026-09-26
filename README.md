# 🛒 Olist E-Commerce SQL Analytics

![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/Language-SQL-orange)
![Dataset](https://img.shields.io/badge/Dataset-Olist%20Brazilian%20E--Commerce-blue)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

An end-to-end SQL analytics project on the **Olist Brazilian E-Commerce Public Dataset**, built with **MySQL**. It covers the full analyst workflow: database design, data import, validation, exploratory analysis, advanced analytics (cohorts, RFM, window functions), query optimization, and business insights.

---

## 📑 Table of Contents

- [Project Overview](#-project-overview)
- [Objectives](#-objectives)
- [Dataset](#-dataset)
- [Tech Stack](#️-tech-stack)
- [Project Structure](#-project-structure)
- [Database Schema](#️-database-schema)
- [SQL Analysis Modules](#-sql-analysis-modules)
- [Business Questions Answered](#-business-questions-answered)
- [SQL Concepts Demonstrated](#-sql-concepts-demonstrated)
- [Getting Started](#-getting-started)
- [Key Insights](#-key-insights)
- [Future Improvements](#-future-improvements)
- [Author](#-author)

---

## 📌 Project Overview

Olist is a Brazilian marketplace that connects small businesses to customers across the country. This project analyzes its transactional data to understand:

- Sales and revenue performance
- Customer behavior and retention
- Product and category performance
- Seller performance
- Payment methods and installments
- Customer reviews and satisfaction
- Delivery operations

Beyond descriptive analysis, the project applies advanced SQL techniques including **CTEs, window functions, ranking, cohort analysis, RFM segmentation**, and **index-based query optimization** using `EXPLAIN`.

---

## 🎯 Objectives

- Analyze overall sales and revenue performance
- Identify top-performing products, categories, and sellers
- Understand customer purchasing behavior
- Identify repeat and high-value customers
- Analyze payment methods and installment usage
- Measure customer satisfaction through review scores
- Evaluate delivery performance and late deliveries
- Perform customer cohort and RFM segmentation
- Optimize query performance with indexes and execution plans

---

## 🗂️ Dataset

**Source:** [Olist Brazilian E-Commerce Public Dataset (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The dataset contains roughly 100K orders placed between 2016 and 2018 and is split across nine related tables:

| Table | Description |
|---|---|
| `customers` | Customer identifiers and location |
| `orders` | Order status and purchase/delivery timestamps |
| `order_items` | Products purchased in each order, with price and freight |
| `order_payments` | Payment type, installments, and value |
| `order_reviews` | Customer review scores and comments |
| `products` | Product attributes and category |
| `sellers` | Seller information and location |
| `geolocation` | ZIP code latitude/longitude data |
| `category_translation` | Portuguese → English category names |

> **Note:** The raw CSV files are not included in this repository (see [Getting Started](#-getting-started)).

---

## 🛠️ Tech Stack

| Category | Tools |
|---|---|
| Database | MySQL 8.0 |
| Client | MySQL Workbench |
| Language | SQL |
| Techniques | Joins, Subqueries, CTEs, Window Functions, Aggregations, Indexing, Query Optimization |

---

## 📁 Project Structure

```text
olist-ecommerce-sql-analytics/
│
├── data/                          # CSV files (not tracked in Git)
│
├── docs/
│   ├── Olist_Ecommerce_Dataset_Overview.pdf
│   └── olist-er-diagram.png
│
├── sql/
│   ├── 01_create_database.sql     # Create database
│   ├── 02_create_tables.sql       # Table definitions, keys, constraints
│   ├── 03_import_data.sql         # Load CSV data
│   ├── 04_data_validation.sql     # Data quality checks
│   ├── 05_sales_analysis.sql      # Revenue and sales analysis
│   ├── 06_customer_analysis.sql   # Customer behavior analysis
│   ├── 07_product_analysis.sql    # Product and category analysis
│   ├── 08_seller_analysis.sql     # Seller performance analysis
│   ├── 09_advanced_analysis.sql   # Delivery, reviews, RFM, cohorts
│   ├── 10_query_optimization.sql  # Indexes and execution plans
│   ├── 11_business_insights.sql   # Business-focused summary queries
│   └── 12_add_foreign_keys.sql    # Foreign Keys definitions
│
├── scripts/
│   ├── clean_orders.py
│   └── clean_reviews.py
│
├── LICENSE
└── README.md
```

---

## 🗄️ Database Schema

### Entity Relationships

```text
customers
    │
    └── orders
          │
          ├── order_items ── products ── category_translation
          │        │
          │        └── sellers
          │
          ├── order_payments
          │
          └── order_reviews
```

`geolocation` links to customers and sellers through ZIP code prefix, and `category_translation` maps product categories to English names.

---

## 🔎 SQL Analysis Modules

### 1. Data Validation — `04_data_validation.sql`
- Row count validation across all tables
- Duplicate detection
- NULL value checks
- Invalid value and date validation
- Referential integrity and orphan record checks

### 2. Sales Analysis — `05_sales_analysis.sql`
- Total revenue, yearly and monthly sales trends
- Average Order Value (AOV)
- Category revenue, top products, and top sellers
- State-level sales
- Payment analysis
- Month-over-month growth
- Revenue contribution analysis

### 3. Customer Analysis — `06_customer_analysis.sql`
- Customer distribution and spending
- Repeat customers and purchase frequency
- Customer lifetime period
- Monthly active customers
- Customer ranking and spending segments
- RFM analysis and customer cohorts

### 4. Product Analysis — `07_product_analysis.sql`
- Product catalog and category performance
- Product revenue and units sold
- Pricing and freight analysis
- Product characteristics
- Sales ranking and unsold products

### 5. Seller Analysis — `08_seller_analysis.sql`
- Seller revenue and order volume
- Seller AOV and ranking
- Freight analysis and product diversity
- Performance segmentation and sales distribution

### 6. Advanced Analysis — `09_advanced_analysis.sql`
- Delivery performance and late delivery analysis
- Review score analysis and revenue vs. review score
- Category and seller satisfaction
- RFM segmentation and customer cohorts
- Top category by state
- Revenue concentration

### 7. Query Optimization — `10_query_optimization.sql`
- Single-column and composite index creation
- `EXPLAIN` and execution plan analysis
- Table size analysis
- Index verification

### 8. Business Insights — `11_business_insights.sql`
Business-focused queries covering top revenue categories, high-value customers, repeat customer rate, high-performing states, seller performance, customer satisfaction, late delivery rates, payment behavior, and revenue concentration.

---

## ❓ Business Questions Answered

- How much total revenue was generated, and how has it trended over time?
- Which product categories generate the most revenue?
- Which products sell the most units?
- Which sellers generate the highest sales?
- Which states contribute most to revenue?
- What share of customers make repeat purchases?
- Which customers have the highest lifetime spending?
- How concentrated is revenue among high-value customers?
- Which payment methods and installment plans are most common?
- How does delivery performance vary, and how often are orders late?
- How are review scores distributed, and how do they relate to delivery and revenue?
- Which products in the catalog have never been sold?

---

## 🧠 SQL Concepts Demonstrated

| Area | Concepts |
|---|---|
| Querying | `SELECT`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT` |
| Joins | `INNER JOIN`, `LEFT JOIN` |
| Conditional logic | `CASE`, `COALESCE`, `NULLIF` |
| Aggregation | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` |
| Advanced SQL | Subqueries, CTEs |
| Window functions | `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `NTILE()`, `LAG()` |
| Date functions | `DATE_FORMAT()`, `DATEDIFF()`, `TIMESTAMPDIFF()` |
| Performance | `CREATE INDEX`, `EXPLAIN` |

---

## 🚀 Getting Started

### Prerequisites

- MySQL 8.0 or later (window functions and CTEs require 8.0+)
- MySQL Workbench (or any MySQL client)

### Setup

**1. Clone the repository**

```bash
git clone https://github.com/Sharif-Abusad/olist-ecommerce-sql-analytics.git
cd olist-ecommerce-sql-analytics
```

**2. Download the dataset**

Download the CSV files from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and place them in the `data/` folder.

**3. Run the SQL scripts in order**

```text
01_create_database.sql
02_create_tables.sql
03_import_data.sql
04_data_validation.sql
05_sales_analysis.sql
06_customer_analysis.sql
07_product_analysis.sql
08_seller_analysis.sql
09_advanced_analysis.sql
10_query_optimization.sql
11_business_insights.sql
```

> If `03_import_data.sql` fails with a `secure_file_priv` error, either move the CSV files to the directory shown by `SHOW VARIABLES LIKE 'secure_file_priv';` or use the Workbench **Table Data Import Wizard**.

**4. Verify the setup**

```sql
USE olist_ecommerce;
SHOW TABLES;
```

---

## 📊 Key Insights

<!-- Replace the placeholders below with the actual findings from your queries. -->

| Area | Finding |
|---|---|
| Revenue | _Total revenue and growth trend_ |
| Categories | _Top categories by revenue_ |
| Customers | _Repeat purchase rate_ |
| Geography | _Top states by revenue_ |
| Delivery | _Late delivery rate and its effect on review scores_ |
| Payments | _Most used payment method and installment behavior_ |

---

## 📈 Future Improvements

- Build an interactive **Power BI** dashboard on top of the database
- Add automated data-cleaning pipelines
- Create automated SQL data-quality checks
- Add further query-performance benchmarks
- Add business KPI dashboards
- Connect the database to a **Python** analytics pipeline

---

## 👤 Author

<div align="center">

**Sharif Abusad**

[![GitHub](https://img.shields.io/badge/GitHub-Sharif--Abusad-181717?style=for-the-badge&logo=github)](https://github.com/Sharif-Abusad)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Sharif--Abusad-0A66C2?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/sharif-abusad)

*If you found this project useful, consider giving it a ⭐ on GitHub — it helps a lot!*

</div>

---

<div align="center">
<sub>Built with ❤️ using LangGraph, FastAPI, and Streamlit</sub>
</div>