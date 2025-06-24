										
										--SQL Zomato Project--

 --Find out the total Users
 select 
	COUNT(*) as Total_Users
 from users
 
--List all users with their name, age, gender, and occupation.
select 
	name, 
	age, 
	gender, 
	occupation 
from users

--List count of Male and Female users
select 
	gender,
	count(*) as Gender_count
from users
group by gender

--List of single and married users

select 
	Marital_Status,
	count(*) as total_count
from users
group by Marital_Status

--Total percentage of gender as per user coun

with married_percentage as (
select 
	Marital_Status,
	count(*) as total_count,
(select Count(*) from users) as total_users
from users
group by Marital_Status
)
select Marital_Status, total_count, total_users,
Concat(round((total_count * 100) / total_users,2), '%') as percentage
from married_percentage

--List of all users occupation based on gender

select 
	Occupation, 
	count(*) as users_count
from users
group by occupation

--Find the average age of users grouped by gender.
select 
	gender,
	AVG(age) as avg_age
from users
group by gender

--List all unique cuisines available in the menu.
select 
	DISTINCT cuisine 
from menu

--Total Orders

select 
	count(*) as total_orders
from orders

--List of all users who placed an order
with orders_placed as 
(
select 
	user_id, 
	name,
	(select count(*) from orders
	where users.user_id = orders.user_id) as total_orders
from users
)
select * from orders_placed
where total_orders > 0
order by total_orders desc

--List of all Max orders placed on which date
--it will find Max and Min orders count

select 
	Max(total_orders) as max_orders,
	MIN(total_orders) as min_orders
from 
(
select 
	order_date,
	COUNT(*) total_orders
from orders
group by order_date
) as t

--Total amount spent by users

select 
	o.user_id, 
	Sum(sales_amount) as total_amount_spent
from orders o
INNER JOIN users u
on u.user_id = o.user_id
group by o.user_id
order by o.user_id 

--Find total number of restaurant based on city

select 
	city, 
	COUNT(name) as restaurant_count
from restaurant
group by city

--List of all Hinjewadi restaurant
select 
	name as restaurant_name
from restaurant
where city like 'Hinje%'

--Find the total number of restaurants in each city.
select 
	city, 
	COUNT(*) as restaurant_count
from restaurant
group by city
order by city

--List all food items with their name and type.

select 
	food_name,
	type as food_type
from food

--Find food type with restaurant name and average price
select 
	r.name as restaurant_name,
	f.Type as food_type,
	Round(avg(m.price),0) as restaurant_price
from restaurant r
INNER JOIN menu m
on r.id = m.r_id
INNER JOIN food f
on m.f_id = f.f_id
group by r.name, f.type
order by restaurant_name 

/*List of all restaurants which price is higher than a average price, also write price category
like restaurant Low price or regular, avg price or moderate and high price premium or use (Gold, Silver, Premium) */

 with higher_than_avg_price as 
 (
 select r_id, price from menu
 where price > 
 (select Round(Avg(price),0) from menu)
 )
select r.id, r.name from higher_than_avg_price
INNER JOIN restaurant r
on r.id = cte.r_id
group by id, r.name;


--Price Category

select r.id, r.name, ROUND(AVG(price),0) as prices,
	Case 
		when AVG(price) < 200 then 'Silver Group'
		When AVG(price) >= 200 and AVG(price) <=500 then 'Gold Group'
		else 'Premium Group'
	end as category
from menu m
INNER JOIN restaurant r
ON r.id = m.r_id
group by r.id, r.name
order by r.id

/* List of all users who ordered food from which restaurant. 
write a query to show username, ordered food and restaurant name */

select u.user_id, u.name as user_name, f.Food_Name, r.name as restaurant_name
from users u
INNER JOIN orders o
ON o.user_id = u.user_id
INNER JOIN restaurant r
ON r.id = o.r_id
INNER JOIN menu m
ON m.r_id =r.id
INNER JOIN food f
ON f.f_id = m.f_id
group by r.name, u.user_id, u.name, f.food_name
order by u.user_id


--Which user order food most time from restaurant
with most_ordered_user as 
(
select name as username, u.user_id, COUNT(o.user_id) as total_orders,
DENSE_RANK() over(order by COUNT(o.user_id) desc) as rank_user
from users u
INNER JOIN orders o
ON u.user_id = o.user_id
group by name, u.user_id
)
select * from  most_ordered_user 
where rank_user = 1

--Get the total sales amount and quantity for each restaurant.

select 
	r.id, 
	SUM(sales_amount) as total_sales,
	SUM(sales_qty) as total_qty
from orders o
inner join restaurant r on r.id = o.r_id
group by r.id
order by r.id

--Show top 5 restaurants based on average rating.
select top 5
	name,
	AVG(rating) as avg_rating
from restaurant
where rating is not null 
group by name
order by avg_rating desc

--Which city has the most restaurants?
select 
	city, 
	COUNT(name) as total_restaurants,
	DENSE_RANK() over(order by COUNT(name) desc)
from restaurant
group by city
order by total_restaurants desc

						-- Intermediate Analysis Questions--

-- List the top 5 users who spent the most on orders.

select top 5
	u.user_id, 
	u.name, 
	COUNT(*) as total_orders,
	SUM(sales_amount) as total_amount
from orders o 
INNER JOIN users u ON u.user_id = o.user_id
group by u.user_id, u.name
order by total_amount desc

-- Find the most popular food item (based on order quantity).

select top 10
	f.Food_Name, 
	SUM(sales_qty) as total_qty 
from orders o
INNER JOIN menu m ON m.r_id = o.r_id
INNER JOIN food f ON f.f_id = m.f_id
group by f.Food_Name
order by total_qty desc

-- Find average sales per day for each restaurant.

select 
	r.name as restaurant_name, 
	SUM(sales_amount) as total_sales, 
	COUNT(DISTINCT order_date) as active_day,
	ROUND(SUM(sales_amount) * 1/COUNT(DISTINCT order_date),2) as avg_sales_per_day
from orders o
INNER JOIN restaurant r ON r.id = o.r_id
where r.name is not null
group by r.name
order by active_day desc

-- List restaurants that offer multiple cuisines.

select name, COUNT(DISTINCT m.cuisine) from restaurant r
INNER JOIN menu m ON m.r_id = r.id
group by name

-- Get the most ordered cuisine per city.

select 
	m.cuisine, 
	city, SUM(o.sales_qty) as total_qty 
from menu m
INNER JOIN restaurant r ON r.id = m.r_id
INNER JOIN orders o ON o.r_id = r.id
group by m.cuisine, city
order by total_qty desc

-- List users who ordered from more than 3 different restaurants.
with diff_restaurant as 
(
select 
	o.user_id, 
	u.name, 
	COUNT(o.r_id) as total_restaurant 
from orders o
INNER JOIN users u ON u.user_id = o.user_id
group by o.user_id, u.name

)
select 
	user_id, 
	name, total_restaurant 
from diff_restaurant
where total_restaurant >= 3
order by user_id

-- Find total sales amount by each cuisine.

select 
	cuisine, 
	SUM(sales_amount) as total_sales
from orders o
INNER JOIN menu m ON m.r_id = o.r_id
group by cuisine

-- What is the gender distribution of users who ordered 'Pizza'?

select 
	Gender, 
	COUNT(*) as user_count 
from users u
INNER JOIN orders o ON u.user_id = o.user_id
INNER JOIN menu m ON m.r_id = o.r_id
INNER JOIN food f ON f.f_id = m.f_id
where f.Food_Name like '%pizza%'
group by Gender

-- Show restaurants where average sales per order is above ₹500.

select 
	r.name, 
	AVG(sales_amount) as Avg_sales 
from orders o
INNER JOIN restaurant r ON r.id = o.r_id
where name is not null
group by r.name
HAVING AVG(sales_amount) > 500
order by Avg_sales 


							-- Advanced Analysis Questions --

-- Find the top 3 most popular food items in each city.

with most_popular_food as
(
select 
	city, 
	f.food_name, 
	SUM(sales_qty) as most_ordered_food 
from restaurant r
INNER JOIN orders o ON o.r_id = r.id
INNER JOIN menu m ON m.r_id = o.r_id
INNER JOIN food f ON f.f_id = m.f_id
group by r.city, f.Food_Name
), rankedfood as
(
select 
	city, 
	Food_Name, 
	most_ordered_food,
	ROW_NUMBER() over(order by most_ordered_food desc) as food_rank
from most_popular_food
)
select 
	city, 
	food_name, 
	most_ordered_food, 
	food_rank 
from rankedfood
where food_rank <= 3

-- Which user ordered the widest variety of food types?

with UserFoodVariety as
(
select 
	name, 
	o.user_id, 
	COUNT(distinct m.f_id) as unique_food_count 
from users u
INNER JOIN orders o ON u.user_id = o.user_id
INNER JOIN menu m ON m.r_id = o.r_id
group by o.user_id, name
) 
select top 5 
	name, 
	USER_ID, 
	unique_food_count 
from UserFoodVariety
order by unique_food_count desc

-- Find the most profitable restaurant based on total sales.

select top 10
	name, 
	SUM(sales_amount) as total_sales 
from orders o 
INNER JOIN restaurant r ON r.id = o.r_id
where name IS NOT NULL
group by r_id, name
order by total_sales desc

-- Which cuisine generates the highest average revenue per item?

with HighestRevenue as 
(
select 
	m.cuisine,
	SUM(sales_qty * m.price) as revenue
from orders o 
INNER JOIN menu m ON m.r_id = o.r_id
group by m.cuisine
), avgrevenu as 
(
select 
	cuisine, 
	ROUND(AVG(revenue), 0) as avg_revenue
from HighestRevenue
group by cuisine
)
select cuisine, avg_revenue from avgrevenu
order by avg_revenue desc

-- Identify seasonal trends: Which food types are most popular in each quarter?
select 
	f.food_name, 
	DATEPART(Quarter, order_date) as quarter, 
	COUNT(f.f_id) as most_popular from orders o
INNER JOIN menu m ON m.r_id = o.r_id
INNER JOIN food f ON f.f_id = m.f_id
group by DATEPART(Quarter, order_date),f.Food_Name
order by most_popular desc

-- Using a window function, rank restaurants by monthly sales within each city.

with Monthlysalesrank as
(
select city, order_date, DATEPART(MONTH, order_date) as order_month,SUM(sales_amount) as total_sales
from orders o
INNER JOIN restaurant r ON r.id = o.r_id
where name IS NOT NULL
group by order_date, city
),
RankedRestaurant as 
(
select city, order_month, total_sales, DENSE_RANK() over(partition by city order by total_sales) as rank from Monthlysalesrank
)
select city, order_month, total_sales, rank from RankedRestaurant
order by city, order_month, rank

