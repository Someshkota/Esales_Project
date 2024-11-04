--changing datatypes --

select * 
from events2

alter table events2
alter column category_id bigint

alter table events2
alter column product_id int

alter table events2
alter column category_code nvarchar(50)


UPDATE events2
SET event_time = CONVERT(date, REPLACE(event_time, ' UTC', ''));

alter table events2
alter column event_time date

alter table events2
alter column price float

-- replacing nulls 

update events2
SET category_code = 'others'
where category_code = ''

update events2
SET brand = 'others'
where brand = ''

select category_code = 'others'
from events2
where category_code = ''

select brand = 'others'
from events2
where brand=''


--removing duplicates

select *
from events2

select distinct user_id,category_id ,category_code,product_id
from events2

WITH CTE AS (
    SELECT user_id, category_id, category_code, product_id,
           ROW_NUMBER() OVER (PARTITION BY user_id, category_id, category_code, product_id ORDER BY (SELECT NULL)) AS row_num
    FROM events2
)
DELETE FROM CTE
WHERE row_num > 1;

--calculating drop offs --
create view DropoffRate as
SELECT 
    (SUM(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) * 1.0 / SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END)) AS ViewToCartRate,
    (SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) * 1.0 / SUM(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END)) AS CartToPurchaseRate
FROM esales..events2;

create view countsview as 
SELECT 
    SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS Views,
    SUM(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS Carts,
    SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS Purchases
FROM esales..events2;


create view event_count_bytime as

SELECT 
    event_time,
    SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS Views,
    SUM(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS Carts,
    SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS Purchases
FROM esales..events2
GROUP BY event_time
ORDER BY event_time;

--conversion rate by segment by user

create view conversionRatebyUser as
SELECT 
    user_id,
    SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS Views,
    SUM(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS Carts,
    SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS Purchases
FROM esales..events2
GROUP BY user_id
ORDER BY user_id;

--
CREATE VIEW event_summary_view AS

SELECT 
    event_time, 
    event_type, 
    category_code, 
    COUNT(*) AS EventCount
FROM 
    esales..events2
GROUP BY 
    event_time, event_type, category_code;






	select * 
from events2

--splitting cateogory from category_code

select substring(category_code,1,CHARINDEX('.',category_code)-1) as category
from events2
where category_code<>'others'


alter table events2
add category_section nvarchar(55)

update events2
set category_section=substring(category_code,1,CHARINDEX('.',category_code)-1)
where category_code<>'others'

update events2
set category_section='others'
where category_section is null

