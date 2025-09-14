
-- Best and worst performing sales agent from each region
SELECT * FROM (
SELECT sp.sales_agent,SUM(close_value) as sales,t.regional_office,
ROW_NUMBER() OVER (PARTITION BY regional_office ORDER BY regional_office,SUM(close_value) DESC)
AS max_min FROM sales_pipeline sp  
LEFT JOIN sales_teams t
ON sp.sales_agent = t.sales_agent
GROUP BY sp.sales_agent,t.regional_office) oo
WHERE max_min  =  1 OR max_min = 10;

/* Spread of revenue from accounts
We see that they receive 40% of the revenue from just 10 accounts posing possible concentration risk */

WITH ts AS (
SELECT account,revenue,
(SELECT SUM(revenue) FROM accounts) AS total_revenue 
FROM accounts),
ts1 AS 
(SELECT *,(revenue/total_revenue)*100 AS percentage_of_revenue FROM ts)
SELECT *,
SUM(percentage_of_revenue) OVER (ORDER BY percentage_of_revenue DESC) AS cumalative_percentage_of_revenue,
ROW_NUMBER() OVER() AS Buyers_rank  FROM ts1;

-- Revenue from each sector
SELECT 
    *,
    (SELECT 
            SUM(close_value)
        FROM
            sales_pipeline) AS percent_sales
FROM
    (SELECT 
        t.regional_office, SUM(close_value) AS sales
    FROM
        sales_pipeline sp
    LEFT JOIN sales_teams t ON sp.sales_agent = t.sales_agent
    GROUP BY regional_office) o;

-- Revenue Split from each product
WITH ts AS (
SELECT product,SUM(close_value) AS revenue,
(SELECT SUM(close_value) FROM sales_pipeline) AS total_revenue FROM sales_pipeline
GROUP BY product)
SELECT *,
(revenue/total_revenue)*100 AS Percent_of_revenue FROM ts
ORDER BY revenue DESC;

-- Avg time taken to convert a lead
SELECT AVG(DATEDIFF(close_date,engage_date)) AS avg_lead_conversion FROM sales_pipeline
WHERE DATEDIFF(close_date, engage_date) IS NOT NULL;

-- Avg time taken to convert a lead per sales agent
SELECT 
    sales_agent,
    AVG(leadconversion_len) AS avg_leadconversionlength
FROM
    (SELECT 
        opportunity_id,
            sales_agent,
            engage_date,
            close_date,
            DATEDIFF(close_date, engage_date) AS leadconversion_len
    FROM
        sales_pipeline
    WHERE
        DATEDIFF(close_date, engage_date) IS NOT NULL) o
GROUP BY sales_agent
ORDER BY avg_leadconversionlength;


-- Sales time series
SELECT 
    close_date, close_value
FROM
    sales_pipeline
WHERE
    close_date IS NOT NULL
        AND close_value IS NOT NULL
ORDER BY close_date;


-- Win Rate per sales agent

SELECT sales_agent,AVG(CASE WHEN deal_stage = 'Won' then 1 else 0 END) AS q
FROM sales_pipeline
GROUP BY sales_agent;

/* OR
SELECT *,(count/total)*100 AS percent FROM (
SELECT *,
SUM(count) OVER(PARTITION BY sales_agent) AS total FROM (
SELECT sales_agent,count(opportunity_id) AS count,deal_stage
FROM sales_pipeline
WHERE deal_stage = 'Lost' OR deal_stage = 'Won'
GROUP BY sales_agent,deal_stage) o) p
WHERE deal_stage = 'Won';
*/




