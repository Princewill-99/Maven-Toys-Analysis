# MAVEN TOYS STORES ANALYSIS
## PROJECT OVERVIEW
This project was carried out to analyze the performance of Maven Toys, a chain of toy stores based in Mexico. The project involved the sales of the company over a period of almost two years from January 2017 to September 2018. It involved a comprehensive analysis into the sales, inventory, products and stores of the company. Here I seek to delve into and explore the data, analyze the trends and characteristics  of the company, and therefore gain valuable insight into the performance and overall standing of the company and its subsidiaries.
## DATA SOURCES
## TOOLS USED
-Microsoft Excel – Data cleaning and preparation
- SQL – Data analysis and exploration
- Tableau – Data visualization
## PROJECT QUESTIONS
1.	What was the total revenue for the period?
2.	What were the stores with the highest sales?
3.	What are the highest selling products?
4.	What products have the highest quantity in inventory across all stores?
5.	Which stores have the highest amount of goods in inventory?
6.	What was the sales in each month?
7.	How many stores were in each city?
8.	What cities had the highest sales/revenue?
9.	What were the highest selling products in each month?

## DATA CLEANING/PREPARATION
The analysis was done using 4 tables, and therefore several data cleaning and transformation techniques were carried out to ensure integrity and usability of the data for the analysis.
-	Loading the csv files into Microsoft Excel for inspection and preparation.
-	Some adhoc analyses were carried out in tables with quantitative fields e.g. inventory, products and sales table to ensure there where were no outliers and to better understand the nature and statistical properties of the data.
-	Duplicates and missing values were handled accordingly
-	The data types of some columns were transformed for the purpose of the analysis.

## DATA ANALYSIS
The dataset was then imported into the postgresql server and my analysis of the data began. Some tasks performed include:
-	Finding the total revenue for the time period:
```sql
select to_char(sum(revenue), 'L99,999,999') as Total_Revenue from
(select *, product_price * units as revenue from
(select a.product_id, a.product_name, a.product_category, a.product_cost, a.product_price,
b.sale_id, b.date, b.store_id, b.units
from toy_products as a inner join toy_sales as b
on a.product_id=b.product_id))
```
-	Identifying the stores with the highest sales:
```sql
select max(store_id) as store_id, store_name, max(store_city) as store_city,
max(store_location) as store_location, max(store_open_date) as store_open_date, 
to_char(sum(revenue), 'L9,999,999') as revenue from
(select a.store_id, a.store_name, a.store_city, a.store_location, a.store_open_date, b.revenue
from toy_stores as a
full join (select *, product_price * units as revenue from
(select a.product_id, a.product_name, a.product_category, a.product_cost, a.product_price,
b.sale_id, b.date, b.store_id, b.units
from toy_products as a full join toy_sales as b
on a.product_id=b.product_id)) as b
on a.store_id=b.store_id)
group by store_name
order by revenue desc
```
This query, and many other queries in this analysis, involved extensive usage of joins and subqueries, as the data was being aggregated from multiple tables. 

-	Identifying the highest selling products:
```sql
select product_name, product_category, to_char(total_revenue, 'L9,999,999.99') as total_revenue from
(select max(product_id) as product_id, product_name, max(product_category) as product_category, 
sum(revenue) as total_revenue from
(select*, units * product_price as revenue from
(select a.product_id, a.product_name, a.product_category, a.product_cost, a.product_price,
b.sale_id, b.date, b.store_id, b.units
from toy_products as a full join toy_sales as b
on a.product_id=b.product_id)) 
group by product_name 
order by total_revenue desc)
```
-	Finding out which products had the highest quantity in inventory across all stores:
```sql
select product_name, max(product_id) as product_id, max(product_category) as product_category,
sum(stock_on_hand) as total_inventory from
(select a.product_name, a.product_id, a.product_category, b.store_id, b.stock_on_hand
from toy_products as a
inner join toy_inventory as b
on a.product_id=b.product_id)
group by product_name
order by total_inventory desc
```
-	Identifying  which stores have the highest amount of goods in inventory:
```sql
select max(store_id) as store_id, store_name, max(store_city) as store_city, max(store_location) as store_location,
max(store_open_date) as store_open_date, sum(stock_on_hand) as total_inventory from
(select a.store_id, a.store_name, a.store_city, a.store_location, a.store_open_date, b.stock_on_hand
from toy_stores as a
inner join toy_inventory as b
on a.store_id=b.store_id)
group by store_name
order by total_inventory desc
```
-	How was the trend of sales over the time period?
```sql
select month, year, to_char(total_revenue, 'L9,999,999') as total_sales from
(select month_num, max(month) as month, max(year) as year, sum(revenue) as total_revenue from
(select *, units * product_price as revenue from
(select *, extract(month from date) as month_num, to_char(date, 'Month') as month, extract(year from date) as year, 
(select product_price from toy_products where toy_sales.product_id = toy_products.product_id)
from toy_sales))
group by month_num, year
order by year, month_num)
```
-	What was the revenue by each city? Which cities had the highest revenue?
```sql
select store_city,
to_char(sum(revenue), 'L9,999,999') as revenue from
(select a.store_id, a.store_name, a.store_city, a.store_location, a.store_open_date, b.revenue
from toy_stores as a
full join (select *, product_price * units as revenue from
(select a.product_id, a.product_name, a.product_category, a.product_cost, a.product_price,
b.sale_id, b.date, b.store_id, b.units
from toy_products as a full join toy_sales as b
on a.product_id=b.product_id)) as b
on a.store_id=b.store_id)
group by store_city
order by revenue desc
```
-	What were the highest selling/revenue generating products in each month?
```sql
select month, year, product_name, to_char(revenue, 'L9,999,999.99') as total_revenue from
(select *, max(revenue) over(partition by month) as max_r from
(select month_num, max(month) as month, max(year) as year, product_name, sum(revenue) as revenue from
(select *, units * product_price as revenue from
(select *, extract(month from date) as month_num, to_char(date, 'Month') as month, extract(year from date) as year, 
(select product_price from toy_products where toy_sales.product_id = toy_products.product_id),
(select product_name from toy_products where toy_sales.product_id = toy_products.product_id)
from toy_sales))
group by product_name, month_num, year)
order by year, month_num)
where revenue = max_r
```
-	What were the highest selling stores in each month?
```sql
select month, year, product_name, to_char(revenue, 'L9,999,999.99') as total_revenue from
(select *, max(revenue) over(partition by month, year) as max_r from
(select month_num, max(month) as month, year, product_name, sum(revenue) as revenue from
(select *, units * product_price as revenue from
(select *, extract(month from date) as month_num, to_char(date, 'Month') as month, extract(year from date) as year, 
(select product_price from toy_products where toy_sales.product_id = toy_products.product_id),
(select product_name from toy_products where toy_sales.product_id = toy_products.product_id)
from toy_sales))
group by product_name, month_num, year)
order by year, month_num)
where revenue = max_r
```
-	What were the highest selling stores in each month?
```sql
select month, year, store_name, store_city, store_location, to_char(revenue, 'l99,999') as revenue from
(select month, year, month_num, store_name, store_city, store_location, revenue, max(revenue) over (partition by month, year) as max_r from
(select month_num, max(month) as month, year, store_name, max(store_city) as store_city, 
 max(store_location) as store_location, sum(revenue) as revenue from
(select *, units * product_price as revenue from
(select *, extract(month from date) as month_num, to_char(date, 'Month') as month, extract(year from date) as year, 
(select product_price from toy_products where toy_sales.product_id = toy_products.product_id),
(select store_name from toy_stores where toy_sales.store_id = toy_stores.store_id),
(select store_city from toy_stores where toy_sales.store_id = toy_stores.store_id),
(select store_location from toy_stores where toy_sales.store_id = toy_stores.store_id)
from toy_sales))
group by store_name, month_num, year)
order by year, month_num)
where revenue = max_r
```
## RESULTS/FINDINGS
- Lego Bricks was the product with the highest revenue, with over $2.3M generated in revenue. It was followed by Colorbuds and Magic Sand.
- Maven Toys Cuidad de Mexico 2 had the highest quabtity of goods in inventory.
- Deck of cards was the product with the highesst quantity in inventory across all stores. Closely following were Dinosaur Figures and PlayDoh Can.
- Maven Toys Cuidad de Mexico 2 generated the highest revenue among all stores, with over $500k generateed in revenue.
- A strong positive relationship was observed between profit and revenue.
## RECOMMENDATIONS
- More investment funds should be channeled towards Maven Toys Cuidad de Mexico 2, as it was the store with the best overall performance. This might be due to large population or high density in its city of location. The management of the chain of stores can take advantage of this large market by expanding the scale of its operations in this city to generate more revenue.
- The analysis showed that Lego Bricks had the highest revenue, indicating high customer interest in and preference for the product. Production and sales of the product should therefore be increased to generate higher profit.
