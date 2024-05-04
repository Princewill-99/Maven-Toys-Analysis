-- 1. What is the total revenue?

select to_char(sum(revenue), 'L99,999,999') as Total_Revenue from
(select *, product_price * units as revenue from
(select a.product_id, a.product_name, a.product_category, a.product_cost, a.product_price,
b.sale_id, b.date, b.store_id, b.units
from toy_products as a inner join toy_sales as b
on a.product_id=b.product_id))

-- 2. What are the stores with highest sales?

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

-- 3. What are the highest selling products?

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

-- 4. What products have the highest quantity in inventory across all stores?

select product_name, max(product_id) as product_id, max(product_category) as product_category,
sum(stock_on_hand) as total_inventory from
(select a.product_name, a.product_id, a.product_category, b.store_id, b.stock_on_hand
from toy_products as a
inner join toy_inventory as b
on a.product_id=b.product_id)
group by product_name
order by total_inventory desc

-- 5. Which stores have the highest amount of goods in inventory?

select max(store_id) as store_id, store_name, max(store_city) as store_city, max(store_location) as store_location,
max(store_open_date) as store_open_date, sum(stock_on_hand) as total_inventory from
(select a.store_id, a.store_name, a.store_city, a.store_location, a.store_open_date, b.stock_on_hand
from toy_stores as a
inner join toy_inventory as b
on a.store_id=b.store_id)
group by store_name
order by total_inventory desc

-- 6. Sales by month

select month, year, to_char(total_revenue, 'L9,999,999') as total_sales from
(select month_num, max(month) as month, max(year) as year, sum(revenue) as total_revenue from
(select *, units * product_price as revenue from
(select *, extract(month from date) as month_num, to_char(date, 'Month') as month, extract(year from date) as year, 
(select product_price from toy_products where toy_sales.product_id = toy_products.product_id)
from toy_sales))
group by month_num, year
order by year, month_num)

-- 7. Number of stores in each city

select store_city, count(store_name) as number_of_stores from toy_stores group by store_city 
order by number_of_stores desc

-- 8. Sales by city

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

-- 9. What were the highest selling products in each month?

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

-- 10. What were the highest selling stores in each month?

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

