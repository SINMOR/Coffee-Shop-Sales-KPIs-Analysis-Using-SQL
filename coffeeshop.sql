SELECT *
FROM coffeeshopsales
ORDER BY transaction_id ASC
-- |DATA CLEANING|
--Change Date and Time format 
SELECT transaction_date,transaction_time
FROM coffeeshopsales
ORDER BY transaction_id ASC
-- transaction date wrong format
-- transaction time wrong format 
SELECT transaction_date,CONVERT(date,transaction_date)
FROM coffeeshopsales
ORDER BY transaction_id ASC
ALTER TABLE coffeeshopsales
ADD transaction_dateconv DATE
UPDATE  coffeeshopsales
SET transaction_dateconv=CONVERT(date,transaction_date)
WHERE transaction_date IS NOT NULL
SELECT transaction_time,CONVERT(time,transaction_time)
FROM coffeeshopsales
ORDER BY transaction_id ASC
ALTER TABLE coffeeshopsales
ADD transaction_timeconv TIME
UPDATE  coffeeshopsales
SET transaction_timeconv=CONVERT(time,transaction_time)
WHERE transaction_date IS NOT NULL
SELECT transaction_dateconv,transaction_timeconv
FROM coffeeshopsales
ORDER BY transaction_id ASC
SELECT transaction_date,transaction_time
FROM coffeeshopsales
ORDER BY transaction_id ASC
-- converted the columns to correct time format 

--Checking for Duplicates 

-- there are no duplicates in the dataset 

-- checking for null values 
-- i will use CASE statements 
SELECT 
COUNT(CASE WHEN transaction_id IS NULL THEN 1 END ) AS transactionidnull,
COUNT(CASE WHEN transaction_dateconv IS NULL THEN 1 END ) AS transactiondatenull,
COUNT(CASE WHEN transaction_timeconv IS NULL THEN 1 END ) AS transactiontimenull,
COUNT(CASE WHEN transaction_qty IS NULL THEN 1 END ) AS transactionqtynull,
COUNT(CASE WHEN store_location IS NULL THEN 1 END ) AS storelocationnull,
COUNT(CASE WHEN store_id IS NULL THEN 1 END ) AS storeidnull,
COUNT(CASE WHEN product_id IS NULL THEN 1 END ) AS productidnull,
COUNT(CASE WHEN unit_price IS NULL THEN 1 END ) AS unitpricenull,
COUNT(CASE WHEN product_category IS NULL THEN 1 END ) AS productcategorynull,
COUNT(CASE WHEN product_type IS NULL THEN 1 END ) AS producttypenull,
COUNT(CASE WHEN product_detail IS NULL THEN 1 END ) AS productdetailnull
FROM coffeeshopsales
-- no null values 

--|DATA ANALYSIS|
--1.Total Sales Revenue 
SELECT SUM(transaction_qty*unit_price)
FROM coffeeshopsales
-- $698812.32

--2.Average Transaction quantity 
SELECT AVG(transaction_qty)
FROM coffeeshopsales
-- $1.4382

--3.Average Sales Revenue per store 
SELECT store_id, AVG(transaction_qty*unit_price) AS Average
FROM coffeeshopsales
GROUP BY store_id
--4.Average unit price by product category 
SELECT product_category, AVG(unit_price) AS Average
FROM coffeeshopsales
GROUP BY product_category
ORDER BY Average DESC
--Coffee Beans is the most expensive followed by Branded then Loose Tea

--5.Top 5 Selling Products by  Revenue  
SELECT product_id ,product_type, (transaction_qty*unit_price)AS Totalsales
FROM coffeeshopsales
GROUP BY product_id,product_type,transaction_qty,unit_price
ORDER BY Totalsales DESC
-- 

--6.Top 5 selling products by Quantity
SELECT product_id ,SUM(transaction_qty) AS TotalQuantity
FROM coffeeshopsales
GROUP BY product_id,transaction_qty
ORDER BY TotalQuantity DESC
--product_id 71 has the highest 

--7.Sale Revenue by product type 
SELECT product_type, SUM(transaction_qty*unit_price)
FROM coffeeshopsales
GROUP BY product_type,transaction_qty,unit_price


