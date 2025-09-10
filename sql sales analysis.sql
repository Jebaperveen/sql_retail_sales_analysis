-- creating database
create database retail_sales;

-- creating table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );

-- analysis of table data

select count(*) from retail_sales_analysis;

select * from retail_sales_analysis
where  transactions_id is null
	   or sale_date is null
	   or sale_time is null
	   or customer_id is null
	   or gender is null
	   or age is null
	   or category is null
	   or quantity is null
	   or price_per_unit is null
	   or cogs is null
	   or total_sale is null

-- data cleaning
delete  from retail_sales_analysis
where  transactions_id is null
	   or sale_date is null
	   or sale_time is null
	   or customer_id is null
	   or gender is null
	   or age is null
	   or category is null
	   or quantity is null
	   or price_per_unit is null
	   or cogs is null
	   or total_sale is null

--	ANALYSIS AND FINDINGS

-- 1 write sql query to retrive all columns for sales made on '2022-11-05
select * from retail_sales_analysis
where sale_date = '2022-11-05'

-- 2 write sql query to retrive all transcation where catrgory is 'clothing' and quantity sold is more than 3	
--in month of nov-2022
select * from retail_sales_analysis
where category = 'Clothing'
	and quantity>=3
	and format(sale_date ,'yyyy-MM') = '2022-11'

--3 write sql query to  calculate total_sales for each category
select 
	category, 
	sum(total_sale) as total_sales 
from retail_sales_analysis
	group by category;

-- 4 find top 5 customers with the highest total sales across all transaction and
-- calculate their contribution percentage to the company's overall sales
with customer_sales as ( 
		select  customer_id,sum(total_sale) as cust_total_sales 
		from retail_sales_analysis
		group by customer_id),
company_total as(
		select sum(total_sale) as total_sales
		from retail_sales_analysis)
select top 5 cs.customer_id ,
		cs.cust_total_sales,
		(cs.cust_total_sales/ct.total_sales)*100  as pct_contribution
		from customer_sales cs
		cross join company_total ct 
		order by cs.customer_id desc
	
		
-- 5  identify the  product category that generates the highest profit margin
-- (total_sales - cogs* quantity )/total_sales and rank categories accordingly
with profit_table as (
        select category,
			   total_sale,
		       (price_per_unit - cogs) * quantity as profit		
from retail_sales_analysis),

profit_margin as 
	( select category, 
			 sum(profit)/sum(total_sale) *100 as sale_profit_margin, 
			 rank() over( order by  sum(profit)/sum(total_sale)*100 desc) as rnk
	  from profit_table group by category)

select category,sale_profit_margin from
profit_margin; 


-- 6  Determine month-on-month sales growth percentage for each product category in 2022.
with monthly_sales as(
	select  month(sale_date) as sale_month,
			category,
			sum(total_sale) as total_monthly_sales
	from retail_sales_analysis
	where year(sale_date) = '2022'
	group by  month(sale_date),category
	),

growth as ( select
				category
				,sale_month,
				total_monthly_sales,
			    lag(total_monthly_sales) over(partition by category order by sale_month) as prev_month_sale
			from monthly_sales)

select 
	category,
	sale_month,
	total_monthly_sales,
	((total_monthly_sales - prev_month_sale)/prev_month_sale)* 100
	as pct_growth from growth
where prev_month_sale is not null


 
-- 7 for each customer, calculate their total number of transactions, total_sales, average order value
-- and then identify  high value customers (spending above the 75th percentile)
with customer_details as (
		select customer_id,
			   count(transactions_id) as total_transaction,
			   sum(total_sale) as total_sales,
			   avg(total_sale) as average_order_value
	  
			from retail_sales_analysis
			group by customer_id),

percent_rnk as ( select customer_id,
                 PERCENT_RANK() over(order by total_sale desc) as rnk
				from retail_sales_analysis )

select c.customer_id,
	   c.total_transaction,
	   c.total_sales,
	   c.average_order_value,
	   case when p.rnk >= 0.75 then 'high value customers' else 'low value customers' end as customer_segment
from customer_details c left join percent_rnk p on 
p.customer_id = c.customer_id
where p.rnk >= 0.75


 
--8  divide customers into age brackets (18-25, 26-35 , 36-50 , 51+) and find out which group generates
-- the highest sales for each category.
with age_category as (
	select 
	    category ,
		total_sale,
		case when age between 18 and 25 then '18-25'
			 when age between 26 and 35 then '26-35'
			 when age between 36 and 50 then '36-50'
			 else '51+' end as age_group
			 
	from retail_sales_analysis)
select category ,
	   age_group,
       sum(total_sale) as total_sales
	   from age_category
group by category, age_group
order by total_sales


 
-- 9 identify customers who made only one transaction in 2022 and 
-- calculate their share in total sales compared to repeat customers.
with cust_txn as(
	 select customer_id , 
	        count(*) as transaction_count ,
			sum(total_sale) as total_sales
		  from retail_sales_analysis
		  where year(sale_date) = '2022'
		  group by customer_id
		  ),
one_time as (
	select  customer_id ,sum(total_sales) as one_time_sale
		from cust_txn
		where transaction_count = 1
		group by customer_id
		),
repeat_cust as (
	 select customer_id, sum(total_sales) as repeat_sales
	    from cust_txn 
		where transaction_count >1
		group by customer_id)

select  o.customer_id,
        o.one_time_sale,
	    r.repeat_sales,
		o.one_time_sale * 100 / (o.one_time_sale + r.repeat_sales) as one_time_pct,
		r.repeat_sales * 100 / (o.one_time_sale + r.repeat_sales) as repeat_pct
	from one_time o 
	cross join repeat_cust r
	


 
-- 10 find the best selling product category per gender and compare sales contribution between male and female customers.
select * from retail_sales_analysis;
with gender_sales as (
	select gender, category ,sum(total_sale) total_sales from retail_sales_analysis
	group by gender , category),

ranked as (
	select gender,
		   category,
		   total_sales,
		   rank() over(partition by gender order by total_sales desc) as rnk
	from gender_sales)
select gender ,
       category,
	   total_sales
	 from ranked where rnk = 1
