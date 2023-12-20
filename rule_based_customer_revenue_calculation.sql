-- Observing the data
SELECT *
FROM gezinomi
LIMIT 10;

-- Unique cities and their frequencies
SELECT salecityname, COUNT(*) as frequency
FROM gezinomi
GROUP BY salecityname
ORDER BY frequency DESC;

-- Unique concept number
SELECT COUNT(DISTINCT conceptname) as unique_concept_count
FROM gezinomi;

-- Sales numbers of each concept
SELECT conceptname, COUNT(*) as concept_count
FROM gezinomi
GROUP BY conceptname
ORDER BY concept_count DESC;

-- Total revenue from each city
SELECT salecityname as city, SUM(price) as total_revenue
FROM gezinomi
GROUP BY city
ORDER BY total_revenue DESC;

-- Total revenue from each concept
SELECT conceptname as concept_name, SUM(price) as total_revenue
FROM gezinomi
GROUP BY concept_name
ORDER BY total_revenue DESC;

-- Price averages for each city
SELECT salecityname as city, AVG(price) as avg_revenue
FROM gezinomi
GROUP BY city
ORDER BY avg_revenue DESC;

-- Price averages for each concept
SELECT conceptname as concept_name, AVG(price) as avg_revenue
FROM gezinomi
GROUP BY concept_name
ORDER BY avg_revenue DESC;

-- Price averages in city and concept breakdown
SELECT salecityname as city, conceptname as concept_name, AVG(price) as avg_revenue
FROM gezinomi
GROUP BY city, concept_name
ORDER BY city, concept_name DESC;

-- Creating a new table and grouping customers by their booking dates
CREATE TABLE gezinomi_v2 AS
SELECT *,
    CASE
        WHEN salecheckindaydiff < 7 THEN 'Last Minuters'
        WHEN salecheckindaydiff BETWEEN 7 AND 29 THEN 'Potential Planners'
        WHEN salecheckindaydiff BETWEEN 30 AND 89 THEN 'Planners'
        ELSE 'Early Bookers'
    END AS customer_type
FROM gezinomi;

-- Count and average price observations in city, concept, customer type breakdown
SELECT salecityname as city, conceptname as concept, customer_type, AVG(price) as avg_price, COUNT(*)
FROM gezinomi_v2
GROUP BY city, conceptname, customer_type
ORDER BY city, conceptname, customer_type DESC;

-- Count and average price observations in city, concept, season breakdown
SELECT salecityname as city, conceptname as concept, seasons, AVG(price) as avg_price, COUNT(*)
FROM gezinomi_v2
GROUP BY city, conceptname, seasons
ORDER BY city, conceptname, seasons DESC;

-- Count and average price observations in city, concept, Weekday breakdown
SELECT salecityname as city, conceptname as concept, cinday, AVG(price) as avg_price, COUNT(*)
FROM gezinomi_v2
GROUP BY city, conceptname, cinday
ORDER BY city, conceptname DESC, 
    CASE
        WHEN cinday = 'Monday' THEN 1
        WHEN cinday = 'Tuesday' THEN 2
        WHEN cinday = 'Wednesday' THEN 3
        WHEN cinday = 'Thursday' THEN 4
        WHEN cinday = 'Friday' THEN 5
        WHEN cinday = 'Saturday' THEN 6
        WHEN cinday = 'Sunday' THEN 7
    END ASC;

-- Creating a new table in city, concept, season breakdown sorted by price
CREATE TABLE sales AS
SELECT salecityname, conceptname, seasons, AVG(price) as avg_price, COUNT(*)
FROM gezinomi_v2
GROUP BY salecityname, conceptname, seasons
ORDER BY avg_price DESC;

-- Creating a new column, level-based sales (persona)
ALTER TABLE gezinomi_v2
ADD COLUMN sales_level_based VARCHAR(50); -- Adjust the data type and size accordingly

UPDATE gezinomi_v2
SET sales_level_based = UPPER(CONCAT(salecityname, '_', conceptname, '_', seasons));

-- Creating a new table and segmenting personas according to their average revenue
CREATE TABLE segments AS
SELECT *,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY price) = 1 THEN 'A'
        WHEN NTILE(4) OVER (ORDER BY price) = 2 THEN 'B'
        WHEN NTILE(4) OVER (ORDER BY price) = 3 THEN 'C'
        WHEN NTILE(4) OVER (ORDER BY price) = 4 THEN 'D'
    END AS segment
FROM gezinomi_v2;

-- Observing statistics of personas
SELECT segment, AVG(price) as avg_price, MIN(price) as min_price, MAX(price) as max_price
FROM segments
GROUP BY segment;
