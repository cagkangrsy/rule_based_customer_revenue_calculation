-- Observing the data
select * from gezinomi limit 10

-- Unique cities and their frequencies
select distinct(salecityname), count(1) from gezinomi
group by salecityname
order by count desc;

-- Unique concept number
select count(distinct(conceptname )) from gezinomi;

-- Sales numbers of each concept
select distinct(conceptname ), count(*) from gezinomi
group by conceptname
order by count desc;

-- Total revenue from each city
select salecityname as City, sum(price) as TotalRevenue from gezinomi
group by City
order by TotalRevenue desc;

-- Total revenue from each concept
select conceptname as ConceptName, sum(price) as TotalRevenue from gezinomi
group by ConceptName
order by TotalRevenue desc;

-- Price averages for each city
select salecityname as City, avg(price) as AvgRevenue from gezinomi
group by City
order by AvgRevenue desc;

-- Price averages for each concept
select conceptname as ConceptName, avg(price) as AvgRevenue from gezinomi
group by ConceptName
order by AvgRevenue desc;

-- Price averages in city and concept breakdown
select salecityname as City, conceptname as ConceptName, avg(price) as AvgRevenue from gezinomi
group by City, ConceptName
order by City, ConceptName desc;

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
select salecityname as city, conceptname as concept, customer_type, avg(price) as avg_price, count(*)
from gezinomi_v2
group by salecityname, conceptname, customer_type
order by salecityname, conceptname, customer_type desc

-- Count and average price observations in city, concept, season breakdown
select salecityname as city, conceptname as concept, seasons , avg(price) as avg_price, count(*)
from gezinomi_v2
group by salecityname, conceptname, seasons
order by salecityname, conceptname, seasons desc

-- Count and average price observations in city, concept, Weekday breakdown
select salecityname as city, conceptname as concept, cinday , avg(price) as avg_price, count(*)
from gezinomi_v2
group by salecityname, conceptname, cinday
order by salecityname, conceptname desc, 
CASE
          WHEN cinday = 'Monday' THEN 1
          WHEN cinday = 'Tuesday' THEN 2
          WHEN cinday = 'Wednesday' THEN 3
          WHEN cinday = 'Thursday' THEN 4
          WHEN cinday = 'Friday' THEN 5
          WHEN cinday = 'Saturday' THEN 6
          WHEN cinday = 'Sunday' THEN 7
     END ASC

-- Creating a new table in city, concept, season breakdown sorted by price
create table sales as
select salecityname, conceptname, seasons, avg(price) as avg_price, count(*)
from gezinomi_v2
group by salecityname, conceptname, seasons
order by avg_price desc

-- Creating a new column,  level-based sales (persona)
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
select segment, avg(price), min(price), max(price) from segments
group by segment 



