-- Question 1 :Is the current shift-wise distribution of employees in keeping with the daily demand? Does it require a change? 

--Number of Supervisors per Shift
select Shift_ID, Day , count(A.Role_ID) as Num_Supervisors from
((select * from rbilaiya.Employee
where Role_ID=2) as A
inner join
(select * from rbilaiya.Emp_Shift) as C
on A.Emp_ID=C.Emp_ID) 
group by Day, Shift_ID
order by Day Asc


-- Number of Associates per Shift
select Shift_ID, Day , count(A.Role_ID) as Num_associates from
((select * from rbilaiya.Employee
where Role_ID=4) as A
inner join
(select * from rbilaiya.Emp_Shift) as C
on A.Emp_ID=C.Emp_ID) 
group by Day, Shift_ID
order by Day Asc


-- Daily Total Orders
select Order_Date, sum(Order_Qty) 
as Total_Daily_Qty
from rbilaiya.Orders
group by Order_date
order by Total_Daily_Qty desc



-- Question 2 : Are the employees being used to their full capacity?

select A.Emp_ID, count(C.Shift_ID) as num_shifts from
((select * from rbilaiya.Employee) as A
inner join
(select * from rbilaiya.Emp_Shift) as C
on A.Emp_ID=C.Emp_ID) 
group by Emp_ID
order by num_shifts desc


-- Question  3 : What is the average daily sales in Lawson OTG? 

SELECT 
avg(Order_Qty) as avg_daily_sales
FROM
(SELECT 
STR_TO_DATE(Order_Date, '%m/%d/%Y') as order_date,
sum(Order_Qty) as Order_Qty
FROM
rbilaiya.Orders
GROUP BY 1
)a;



-- Question  4 : Which are the two days that are the busiest?

SELECT DAYNAME(STR_TO_DATE(Order_Date, '%m/%d/%Y')) AS TOP2_WeekDay, SUM(Order_Qty) AS T_ORD
FROM rbilaiya.Orders
GROUP BY WEEKDAY(STR_TO_DATE(Order_Date, '%m/%d/%Y'))
Order by T_ORD DESC
LIMIT 2;

-- Question  5 : What are the food items that are most and least in-demand?


-- Most in demand:
SELECT
 a.Product_ID,
 Product_Name,
 sum(Order_Qty) as demand
 FROM 
	rbilaiya.Orders a, rbilaiya.Product b
WHERE a.Product_ID = b.Product_ID
GROUP BY 1,2
ORDER BY demand desc 
LIMIT 3;

-- Least in demand:
SELECT
 a.Product_ID,
 Product_Name,
 sum(Order_Qty) as demand
 FROM 
	rbilaiya.Orders a, rbilaiya.Product b
WHERE a.Product_ID = b.Product_ID
GROUP BY 1,2
ORDER BY demand asc 
LIMIT 3;




-- Question  6 : What are the recommended best-selling combinations?

DROP TABLE IF EXISTS rbilaiya.Product_Item_Qty_Temp;
CREATE TEMPORARY TABLE rbilaiya.Product_Item_Qty_Temp AS 
SELECT ord.Product_id, Item.Category_ID, Item.Item_id, SUM(PI.Item_Qty) AS famous_item
FROM rbilaiya.Orders ord
INNER JOIN rbilaiya.Order_Item PI ON ord.order_id=PI.order_id
LEFT JOIN rbilaiya.Item ON PI.Item_ID=Item.Item_ID
GROUP BY ord.Product_id , Item.Category_ID, Item.Item_id
ORDER BY ord.Product_id , Item.Category_ID, Item.Item_id, famous_item;

DROP TABLE IF EXISTS rbilaiya.Product_Fms_Item_Temp;
CREATE TEMPORARY TABLE rbilaiya.Product_Fms_Item_Temp AS 
SELECT famous.Product_id, famous.Category_ID, max(famous_item) fms
FROM rbilaiya.Product_Item_Qty_Temp famous
GROUP BY famous.Product_id, famous.Category_ID;

SELECT P.Product_Name, Item.Item_Name 
FROM rbilaiya.Product_Item_Qty_Temp T
INNER JOIN rbilaiya.Product_Fms_Item_Temp T2 ON T.Product_id=T2.Product_id AND T.Category_ID=T2.Category_ID AND T.famous_item=T2.fms
INNER JOIN rbilaiya.Item ON Item.Item_id=T.Item_ID
INNER JOIN rbilaiya.Product P ON P.Product_ID=T.Product_ID
ORDER BY P.Product_Name;





-- Question  7 : How is the resource planning and management to account for food inspection and expiry?


DROP TABLE IF EXISTS rbilaiya.cat_item;
CREATE TABLE rbilaiya.cat_item
(SELECT 
	a.Category_ID,
    a.Min_Expiry_Check_Duration,
    b.Item_ID,
    b.Item_Name
FROM
	rbilaiya.Category a, rbilaiya.Item b
WHERE a.Category_ID = b.Category_ID
GROUP BY 1,2,3
);

SELECT 
	DATE_ADD(Expiry_Date, INTERVAL -1 DAY) as Inspect_Date,
    COUNT(DISTINCT Purchase_Quantity) as tot_inspect_items,
    SUM(Purchase_Quantity) AS tot_inspect_qty
FROM
(SELECT
	a.Item_ID, 
    Item_Name,
    Min_Expiry_Check_Duration,
    Purchase_Quantity,
    STR_TO_DATE(Purchase_Date, '%m/%d/%Y') as Purchase_Date,
    DATE_ADD(STR_TO_DATE(Purchase_Date, '%m/%d/%Y'), INTERVAL Min_Expiry_Check_Duration DAY) as Expiry_Date
FROM
	rbilaiya.Vendor_Item a
INNER JOIN 
	rbilaiya.cat_item b
ON a.Item_ID = b.Item_ID
WHERE Min_Expiry_Check_Duration <> -99 and Min_Expiry_Check_Duration <> -1
)a
GROUP BY 1
ORDER BY tot_inspect_qty desc
;



-- Question  8 : Which item and category should be replenished soon based on the difference between order quantity and supply quantity?

SELECT 
	item_ID, 
    Item_Name, 
    stock_qty - used_qty as rem_qty
FROM
(SELECT 
	a.*,
    b.Purchase_Quantity as stock_qty,
    c.Item_Qty as used_qty
FROM 
	rbilaiya.Item a
INNER JOIN 
	rbilaiya.Vendor_Item b 
ON a.Item_ID = b.Item_ID
INNER JOIN 
	rbilaiya.Order_Item c
ON a.Item_ID = c.Item_ID
WHERE Purchase_Quantity >= Item_Qty
)a
GROUP BY 1,2,3
ORDER BY rem_qty asc



-- Question  9 : What is the most frequent payment mode?

SELECT Payment_Type as Most_Frequent_Payment, COUNT(Payment_Type) FROM rbilaiya.Orders
GROUP BY Most_Frequent_Payment 
ORDER BY COUNT(Payment_Type) desc limit 1;


-- Question 10 :Which vendors supply the categories of items that are purchased the most ordered by the quantity they supply and frequency they supply?


SELECT C.Category_Name, V.Vendor_Name, MAX(total_sum) AS MAX_Vendor_Qty FROM
(Select Vendor_Item.Vendor_ID, SUM(Vendor_Item.Purchase_Quantity) AS total_sum, 
Category.Category_ID
FROM rbilaiya.Vendor_Item
INNER JOIN rbilaiya.Item ON Vendor_Item.Item_ID = Item.Item_ID
INNER JOIN rbilaiya.Category ON Item.Category_ID = Category.Category_ID
GROUP BY Vendor_ID, Category_ID
order by SUM(Purchase_Quantity) DESC) AS TEMP
INNER JOIN rbilaiya.Category C ON TEMP.Category_ID = C.Category_ID
INNER JOIN rbilaiya.Vendor V ON TEMP.Vendor_ID = V.Vendor_ID
group by TEMP.Category_ID;


