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
WITH Duplicates AS( 
    SELECT *, ROW_NUMBER() OVER(PARTITION BY transaction_id,transaction_date,transaction_time ORDER BY transaction_id ASC ) AS RowNum 
    FROM coffeeshopsales
)
SELECT *
FROM Duplicates
WHERE RowNum>1

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
SELECT product_id , SUM (transaction_qty*unit_price)AS Totalsales
FROM coffeeshopsales
GROUP BY product_id
ORDER BY Totalsales DESC
-- Product ID 61

--6.Top 5 selling products by Quantity
SELECT product_id ,SUM(transaction_qty) AS TotalQuantity
FROM coffeeshopsales
GROUP BY product_id,transaction_qty
ORDER BY TotalQuantity DESC
--product_id 50 has the highest 

--7.Sale Revenue by product type 
SELECT product_type, SUM(transaction_qty*unit_price)
FROM coffeeshopsales
GROUP BY product_type

--8.Sale Revenue by product category  
SELECT product_category, SUM(transaction_qty*unit_price) AS totalsales
FROM coffeeshopsales
GROUP BY product_category

--9.Monthly Sales Trend/Sales Revenue by month  
SELECT MONTH(transaction_dateconv), SUM(transaction_qty*unit_price) AS totalsales
FROM coffeeshopsales
GROUP BY MONTH(transaction_dateconv)
ORDER BY  totalsales DESC

--10.Sales Revenue by day of the week 
SELECT day(transaction_dateconv) AS Day, SUM(transaction_qty*unit_price) AS totalsales
FROM coffeeshopsales
GROUP BY day(transaction_dateconv)
ORDER BY  Day DESC

--11.Busiest Store by Transanction Qty 
SELECT store_id, SUM(transaction_qty) AS totaltransactionqty
FROM coffeeshopsales
GROUP BY store_id
ORDER BY totaltransactionqty DESC

--12.Average Transaction value 
SELECT AVG(transaction_qty*unit_price) AS Average 
FROM coffeeshopsales

--13.Top 10 products by sale revenue 
SELECT product_type, SUM(transaction_qty*unit_price)AS Totalsales
FROM coffeeshopsales
GROUP BY product_type
ORDER BY Totalsales DESC
--Barista Espresson

--14.Product Category contribution to Total sales 
SELECT 
    product_category,
    SUM(unit_price * transaction_qty) / 
    (SELECT SUM(unit_price * transaction_qty) 
    FROM coffeeshopsales) AS Contribution
FROM coffeeshopsales
GROUP BY product_category
ORDER BY Contribution DESC;

--15.Monthly Growth Rate 
WITH MonthlySales AS (
    SELECT 
      MONTH(transaction_dateconv) AS Month,
        SUM(unit_price * transaction_qty) AS MonthlySales
    FROM coffeeshopsales
    GROUP BY MONTH(transaction_dateconv)
)
SELECT 
    Month,
    MonthlySales,
   COALESCE( LAG(MonthlySales) OVER (ORDER BY Month),0) AS PrevMonthSales,
   COALESCE( (MonthlySales - LAG(MonthlySales) OVER (ORDER BY Month)) / LAG(MonthlySales) OVER (ORDER BY Month) * 100 , 0)AS GrowthRate
FROM MonthlySales
ORDER BY Month

--16.Cumulative Monthly Sales 
SELECT 
     MONTH(transaction_dateconv)AS Month,
    SUM(SUM(unit_price * transaction_qty)) OVER (ORDER BY MONTH(transaction_dateconv)) AS CumulativeSales
FROM coffeeshopsales
GROUP BY MONTH(transaction_dateconv) 
ORDER BY Month;

--17.Customer Retention Rate 
WITH CustomerTransactions AS (
    SELECT store_id, COUNT(DISTINCT transaction_date) AS NumTransactions
    FROM coffeeshopsales
    GROUP BY store_id
)
SELECT 
    NumTransactions,
    COUNT(store_id) AS NumCustomers,
    (COUNT(store_id) - COUNT(CASE WHEN NumTransactions = 1 THEN store_id END)) / COUNT(store_id) * 100 AS RetentionRate
FROM CustomerTransactions
GROUP BY NumTransactions
--  The  retention rate is 100%

--18.Average Transactions Per day 
SELECT COUNT(DISTINCT transaction_date) AS NumDays,
       COUNT(transaction_id) / COUNT(DISTINCT transaction_date) AS AvgTransactionsPerDay
FROM coffeeshopsales

--19.Monthly Active Customers 
SELECT 
   MONTH(transaction_date) AS Month,
    COUNT(DISTINCT store_id) AS MonthlyActiveCustomers
FROM coffeeshopsales
GROUP BY MONTH(transaction_date)
ORDER BY Month

--20.Calculate Running total of Daily transactions 
SELECT 
       DISTINCT transaction_dateconv,
        SUM(unit_price * transaction_qty),SUM(SUM(unit_price * transaction_qty)) OVER (ORDER BY transaction_dateconv)  AS RunningTotal
    FROM coffeeshopsales
GROUP BY transaction_dateconv
ORDER BY transaction_dateconv ASC

--21.Caluclate The Delta values for Unit prices 
SELECT 
    transaction_id,
    unit_price,
    unit_price - LAG(unit_price) OVER (ORDER BY transaction_id) AS PriceDelta
FROM coffeeshopsales
ORDER BY transaction_id ASC

--22.. Pivoting Data with CASE WHEN for Product Types
SELECT 
  product_category,
    SUM(CASE WHEN product_type = 'Gourmet brewed coffee' THEN 1 ELSE 0 END) AS Gourmetcount,
    SUM(CASE WHEN product_type = 'Brewed Chai tea' THEN 1 ELSE 0 END) AS BrewedChaiCount,
    SUM(CASE WHEN product_type = 'Scone' THEN 1 ELSE 0 END) AS FlavoredCount
FROM coffeeshopsales
GROUP BY product_category


