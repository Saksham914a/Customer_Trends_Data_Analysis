-- use customer_behavior;


-- Total revenue gen. by male and female
SELECT gender, SUM(purchase_amount) as revenue
from customer
group by gender;

-- Customer used discount and yet purchase more than avg amount
select customer_id, item_purchased, purchase_amount 
from customer
where discount_applied = 'Yes' and purchase_amount >= (select Avg(purchase_amount) from customer);

-- Top5 product with highest avg review rating
select item_purchased, round(avg(review_rating), 2) as 'Avg Rating'
from customer
group by item_purchased
order by avg(review_rating) desc limit 5;  

-- Avg purchase amount b/w standard & express shipping type
select shipping_type, round(avg(purchase_amount), 2)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type;

-- Subscribers spend more ? compare b/w sub. & non-sub
select subscription_status,
count(customer_id) as total_customer,
round(Avg(purchase_amount),2) as avg_spend,
sum(purchase_amount) as total_revenue
from customer
group by subscription_status
order by total_revenue desc;

-- Top5 products with highest % of purchase and discount applied
select item_purchased,
round(100 * sum(case when discount_applied = 'Yes' then 1 else 0 end)/count(*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate  desc limit 5;

-- Segment customer into new, returning , loyal based on their total no. purchase 
with customer_type as(
select previous_purchases,
case 
when previous_purchases = 1 then "New"
when previous_purchases between 2 and 10 then "Returning"
else "Loyal" end as customer_segment
from customer
)
select customer_segment, count(*) as "Number of customer"
from customer_type
group by customer_segment;

-- Top3 purchased products in each category
with item_counts as (
select category, item_purchased,
count(customer_id) as total_orders,
row_number() over(partition by category order by count(customer_id) desc) as item_rank
from customer
group by category, item_purchased
)
select category,item_purchased,item_rank,total_orders
from item_counts
where item_rank <=3;

-- Repeat buyers (more than 5 previous purchases) also likely to susbcribe
select subscription_status,
count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status;

-- Total revenue contribution by each age group
select age_group,
sum(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc;