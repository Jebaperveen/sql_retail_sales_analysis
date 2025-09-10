*** Project Overview ***

This project focuses on analyzing retail sales data using SQL.
It covers data cleaning, exploratory analysis, customer segmentation, and business insights.
The dataset contains transactional-level details such as sales date, customer demographics, product categories, pricing, and profit margins.

The analysis helps answer key business questions, such as:
--Which product categories drive the highest sales and profit margins?
--Who are the top customers and their contribution to total revenue?
--How do sales vary by customer age groups and gender?
--What is the month-on-month sales growth trend?
--What percentage of revenue comes from repeat vs one-time customers?

*** Dataset Details ***

The dataset (retail_sales_analysis) includes the following key columns:
transactions_id – Unique transaction identifier
sale_date, sale_time – Date & time of sale
customer_id – Unique customer identifier
gender, age – Customer demographics
category – Product category
quantity, price_per_unit, cogs, total_sale – Sales and cost details

*** Data Cleaning ***

Before performing analysis, rows with missing critical values (transactions_id, sale_date, customer_id, category, sales metrics) were removed:

delete from retail_sales_analysis
where transactions_id is null
   or sale_date is null
   or sale_time is null
   or customer_id is null
   or gender is null
   or age is null
   or category is null
   or quantity is null
   or price_per_unit is null
   or cogs is null
   or total_sale is null;

Analysis & SQL Queries
Sales on Specific Date

--Retrieve all transactions on 2022-11-05. :- Category Filter – Clothing Sales in Nov 2022
--Find transactions where category = Clothing and quantity > 3.
--Total Sales by Category :- Aggregate sales per product category.
--Top 5 Customers & Contribution % :- Identify top 5 customers by total sales and their revenue share.
--Profit Margin by Category :- Calculate and rank product categories by profit margin.
--Month-on-Month Sales Growth :- Compute MoM growth % by category for 2022.
--High Value Customers (75th Percentile) :- Segment customers into high value vs low value using percentile ranking.
--Sales by Age Group & Category :- Group customers into age brackets (18–25, 26–35, 36–50, 51+) and find top spending groups.
--One-Time vs Repeat Customers :- Compare sales contribution from one-time buyers vs repeat customers.
--Best-Selling Category by Gender :- Identify the top product category per gender and compare sales.

*** Key Insights ***

Clothing category had strong sales in November 2022 when quantities exceeded 3 per transaction.
Top 5 customers contributed significantly to overall revenue.
Certain age brackets (26–35) were consistently driving the highest sales.
Repeat customers generated a much larger share of revenue compared to one-time buyers.
Profit margins varied by category, with some outperforming others despite lower sales volume.

*** Tech Stack ***
SQL Server / PostgreSQL / MySQL 






