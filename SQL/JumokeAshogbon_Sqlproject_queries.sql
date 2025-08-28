--1. Which paper types are most in demand across regions based on quantity purchased?

WITH Unpivoted_table AS (SELECT account_id, 'Standard' AS paper_type, standard_qty AS qty
FROM orders
WHERE standard_qty > 0

UNION ALL 

SELECT account_id, 'Poster', poster_qty
FROM orders
WHERE poster_qty > 0

UNION ALL

SELECT account_id, 'Gloss', gloss_qty
FROM orders
WHERE gloss_qty > 0
 ) 
SELECT  u.paper_type,
	region.name AS region_name,
	SUM(qty) AS total_qty
FROM unpivoted_table u
JOIN accounts 
ON accounts.id=u.account_id
JOIN sales_reps 
ON sales_reps.id=accounts.sales_rep_id
JOIN region
ON region.id=sales_reps.region_id
GROUP BY region.name,u.paper_type
ORDER BY total_qty DESC;




--2. Who Are the Top 10 Revenue-Generating Customers by Region?

SELECT 
        accounts.name AS cust_name,
        region.name AS region,
        SUM(total_amt_usd) AS total_revenue
FROM orders
JOIN accounts 
ON accounts.id=orders.account_id
JOIN sales_reps 
ON sales_reps.id=accounts.sales_rep_id
JOIN region
ON region.id=sales_reps.region_id
GROUP BY accounts.name,
         region.name
ORDER BY total_revenue DESC
LIMIT 10;





--3. Which regions generate the most revenue, and what is the average order value in each region?

SELECT 
  region.name,
  SUM(total_amt_usd) AS total_revenue,
  AVG(total_amt_usd)  AS avg_order_value
FROM orders
JOIN accounts 
ON accounts.id = orders.account_id
JOIN sales_reps
ON sales_reps.id = accounts.sales_rep_id
JOIN region 
ON region.id = sales_reps.region_id
GROUP BY region.name
ORDER BY total_revenue DESC;




--4. Who manages our highest-grossing clients, and through whom are these clients contacted?
 
 SELECT 
    accounts.name AS cust_name,
	accounts.primary_poc,
	sales_reps.name AS sales_reps,
	SUM(total_amt_usd) AS total_revenue
FROM orders
JOIN accounts 
ON accounts.id=orders.account_id
JOIN sales_reps 
ON sales_reps.id=accounts.sales_rep_id
GROUP BY accounts.name,
	 accounts.primary_poc,
	 sales_reps.name
ORDER BY total_revenue DESC
LIMIT 10;






--5. Which sales reps are underperforming in terms of paper type quantities sold, and could reassignment of 
--high-performing reps improve sales of low-demand products?


WITH Unpivoted_table AS (SELECT account_id, 'Standard' AS paper_type, standard_qty AS qty
FROM orders
WHERE standard_qty > 0

UNION ALL

SELECT account_id, 'Poster', poster_qty
FROM orders
WHERE poster_qty > 0

UNION ALL

SELECT account_id, 'Gloss', gloss_qty
FROM orders
WHERE gloss_qty > 0
 ) 
SELECT  u.paper_type,
	    sales_reps.name AS sales_rep,
	    SUM(qty) AS total_qty
FROM unpivoted_table u
JOIN accounts 
ON accounts.id=u.account_id
JOIN sales_reps 
ON sales_reps.id=accounts.sales_rep_id
JOIN region
ON region.id=sales_reps.region_id
GROUP BY sales_reps.name,u.paper_type
ORDER BY total_qty ASC
LIMIT 10;





	

--6.  Which Marketing Channels Drive the Most Orders and Highest Revenue?

SELECT
     web_events.channel AS marketing_channel,
     COUNT(*) AS num_of_orders,
     SUM(orders.total_amt_usd) AS total_sales
FROM orders
JOIN web_events
ON web_events.account_id=orders.account_id
WHERE total_amt_usd>0
GROUP BY  web_events.channel
ORDER BY total_sales DESC
LIMIT 10;
	
   


--7. How Have Average Order Value and Total Revenue Evolved Annually from 2013 to 2017?

SELECT
     DATE_PART('year', orders.occurred_at)AS Year,
	 AVG(total_amt_usd) AS Avg_order_value,
	 SUM(orders.total_amt_usd) AS total_revenue
FROM orders
WHERE total_amt_usd>0
GROUP BY Year
ORDER BY Year;




--What are the monthly sales trends across different regions over the past five years
--and are there consistent peak months shared across all years and regions?"

SELECT
         region.name AS region,
         DATE_PART('year', orders.occurred_at)AS Year,
	 DATE_PART('month', orders.occurred_at)AS Month_number,
	 TO_CHAR(orders.occurred_at, 'Month') AS month_name,
	 SUM(orders.total_amt_usd) AS total_revenue
FROM orders
JOIN accounts 
ON accounts.id=orders.account_id
JOIN sales_reps 
ON sales_reps.id=accounts.sales_rep_id
JOIN region
ON region.id=sales_reps.region_id
WHERE total_amt_usd>0 
AND orders.occurred_at BETWEEN '2013-01-01'AND '2017-01-02'
GROUP BY month_name, region.name,year,month_number
ORDER BY year,Month_number,region;


   


--8. How long does it take each customer to place their first order after their first web interaction?


SELECT 
    orders.account_id,
    accounts.name AS cust_name,
	MIN(web_events.occurred_at) AS first_visit,
	MIN(orders.occurred_at) AS first_order,
	MIN(orders.occurred_at) - MIN(web_events.occurred_at) AS time_to_decision
FROM orders
JOIN web_events
ON orders.account_id=web_events.account_id
JOIN accounts ON accounts.id=web_events.account_id
GROUP BY orders.account_id, accounts.name
ORDER BY time_to_decision ASC;


 

--9. How frequently do our customers make purchases, and how can we categorize them based on their order volume?

SELECT
    orders.account_id,
    accounts.name AS cust_name,
    COUNT(*)AS num_of_orders,
 CASE 
    WHEN COUNT(*)> 30 THEN 'High'
    WHEN COUNT(*) BETWEEN 10 AND 30 THEN 'Moderate'
    ELSE 'Low'
END AS purchase_frequency
FROM orders
JOIN accounts
ON accounts.id=orders.account_id
GROUP BY
       orders.account_id,
       accounts.name
ORDER BY num_of_orders DESC;




--10. What is the trend of daily order volumes in year 2016(the most productive year)?

SELECT
         DATE_PART('DOW', orders.occurred_at)AS Day_number,
	 DATE_PART('year', orders.occurred_at)AS year,
	 TO_CHAR(orders.occurred_at, 'Day') AS day_name,
	 COUNT(*) AS num_of_orders
FROM orders
JOIN accounts 
ON accounts.id=orders.account_id
JOIN sales_reps 
ON sales_reps.id=accounts.sales_rep_id
JOIN region
ON region.id=sales_reps.region_id
WHERE total_amt_usd>0 
AND orders.occurred_at BETWEEN '2016-01-01' AND '2016-12-31'
GROUP BY day_name, year,day_number
ORDER BY num_of_orders DESC;






