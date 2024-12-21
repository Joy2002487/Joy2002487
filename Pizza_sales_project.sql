-- retive the total number of orders placed.

select count(order_id) as total_order from orders;


-- calculated the total revenue generated from pizza sales 


SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
    
-- identify the highest - priced of pizza.

select pizza_types.name, pizzas.price
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;


-- identifi the most comon pizza sales quantity wise details

select quantity, count(order_details_id)
from order_details group by quantity;


-- identify the the most comon pizza size ordered.

select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by order_count desc;

-- list the 5 most order pizza types along with thier quantities.

select pizza_types.name, sum(order_details.quantity) as quantity
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name 
order by quantity desc limit 5;

-- part 2  			join the necessary tables to find the total quantity of each pizza category ordered

select pizza_types.category, sum(order_details.quantity)
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category;

-- determine the distribution of orders by hour of the day.
select hour(order_time) as hour, count(order_id) as order_count from orders
group by hour(order_time);


-- join the relevent tables to find the category_wise distribution of pizzas.

select category, count(name) as names_pizza from pizza_types
group by category;


-- group the orders by date and calculate the average number of pizzas ordered per day.alter
select round(avg(quantity),0) as avg_pizza from (
select orders.order_date, sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as orders_quantiy ;

-- determine the top 3 most ordered pizza types based on revenue. 

select pizza_types.name, 
sum(order_details.quantity * pizzas.price) as revenue 
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc limit 3;

-- calculate the percentage contribution of eaach piizza type to total revenue


select pizza_types.category,
round( sum(order_details.quantity * pizzas.price) / (select round(sum(order_details.quantity * pizzas.price),2)
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id) * 100,2) as percentage
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category;

-- analye the  qumelative generate over time 
select order_date, sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date, sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on order_details.order_id = orders.order_id
group by orders.order_date ) as sales ;


-- determine the top 3 most order pizza besed on revenue for each pizza_catagory
select name, category, revenue 
from
(select name,category, revenue,
rank() over(partition by category order by revenue desc) as Top_3
from
(select pizza_types.name, pizza_types.category, sum(order_details.quantity * pizzas.price) as revenue
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name, pizza_types.category) as revenue) as Data_ 
where Top_3 <= 3;