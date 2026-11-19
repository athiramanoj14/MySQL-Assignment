USE ecomm;
SET SQL_SAFE_UPDATES = 0;

-- 1. Impute mean (rounded to nearest integer)
SET @mean_wth = (
    SELECT ROUND(AVG(WarehouseToHome))
    FROM customer_churn
    WHERE WarehouseToHome IS NOT NULL
);
UPDATE customer_churn
SET WarehouseToHome = @mean_wth
WHERE WarehouseToHome IS NULL;

SET @mean_hrs = (
    SELECT ROUND(AVG(HourSpendOnApp))
    FROM customer_churn
    WHERE HourSpendOnApp IS NOT NULL
);
UPDATE customer_churn
SET HourSpendOnApp = @mean_hrs
WHERE HourSpendOnApp IS NULL;

SET @mean_hike = (
    SELECT ROUND(AVG(OrderAmountHikeFromlastYear))
    FROM customer_churn
    WHERE OrderAmountHikeFromlastYear IS NOT NULL
);
UPDATE customer_churn
SET OrderAmountHikeFromlastYear = @mean_hike
WHERE OrderAmountHikeFromlastYear IS NULL;

SET @mean_days = (
    SELECT ROUND(AVG(DaySinceLastOrder))
    FROM customer_churn
    WHERE DaySinceLastOrder IS NOT NULL
);
UPDATE customer_churn
SET DaySinceLastOrder = @mean_days
WHERE DaySinceLastOrder IS NULL;

-- 2. Impute mode for Tenure, CouponUsed, and OrderCount
SET @mode_tenure = (
    SELECT Tenure
    FROM customer_churn
    WHERE Tenure IS NOT NULL
    GROUP BY Tenure
    ORDER BY COUNT(*) DESC
    LIMIT 1
);
UPDATE customer_churn
SET Tenure = @mode_tenure
WHERE Tenure IS NULL;

SET @mode_coupon = (
    SELECT CouponUsed
    FROM customer_churn
    WHERE CouponUsed IS NOT NULL
    GROUP BY CouponUsed
    ORDER BY COUNT(*) DESC
    LIMIT 1
);
UPDATE customer_churn
SET CouponUsed = @mode_coupon
WHERE CouponUsed IS NULL;

SET @mode_orders = (
    SELECT OrderCount
    FROM customer_churn
    WHERE OrderCount IS NOT NULL
    GROUP BY OrderCount
    ORDER BY COUNT(*) DESC
    LIMIT 1
);
UPDATE customer_churn
SET OrderCount = @mode_orders
WHERE OrderCount IS NULL;

-- 3. Delete rows where WarehouseToHome > 100
DELETE FROM customer_churn
WHERE WarehouseToHome > 100;

-- 4. Standardize text values
UPDATE customer_churn
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone';

UPDATE customer_churn
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile';

UPDATE customer_churn
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD';

UPDATE customer_churn
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC';

-- 1. Rename columns
ALTER TABLE customer_churn
RENAME COLUMN PreferedOrderCat TO `Preferred OrderCat`;

ALTER TABLE customer_churn
RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;

-- 2. Add and populate new columns
ALTER TABLE customer_churn
ADD COLUMN ComplaintReceived VARCHAR(10),
ADD COLUMN ChurnStatus VARCHAR(15);

UPDATE customer_churn
SET ComplaintReceived = CASE WHEN (Complain + 0) = 1 THEN 'Yes' ELSE 'No' END;

UPDATE customer_churn
SET ChurnStatus = CASE WHEN (Churn + 0) = 1 THEN 'Churned' ELSE 'Active' END;

-- 3. Drop Churn and Complain columns
ALTER TABLE customer_churn
DROP COLUMN Churn,
DROP COLUMN Complain;

USE ecomm;

-- 1. Count of churned and active customers
SELECT 
    ChurnStatus,
    COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY ChurnStatus;

-- 2. Average tenure and total cashback amount of churned customers
SELECT 
    ROUND(AVG(Tenure), 2) AS AvgTenure,
    ROUND(SUM(CashbackAmount), 2) AS TotalCashbackAmount
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- 3. Percentage of churned customers who complained
SELECT 
    ROUND(
        SUM(CASE WHEN ComplaintReceived = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS ChurnedComplaintPercentage
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- 4. City tier with highest churned customers (Preferred OrderCat = 'Laptop & Accessory')
SELECT 
    CityTier,
    COUNT(*) AS ChurnedCustomers
FROM customer_churn
WHERE ChurnStatus = 'Churned'
  AND `Preferred OrderCat` = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY ChurnedCustomers DESC
LIMIT 1;

-- 5. Most preferred payment mode among active customers
SELECT 
    PreferredPaymentMode,
    COUNT(*) AS ActiveCustomers
FROM customer_churn
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY ActiveCustomers DESC
LIMIT 1;

-- 6. Total order amount hike from last year (Single & Mobile Phone)
SELECT 
    ROUND(SUM(OrderAmountHikeFromlastYear), 2) AS TotalOrderAmountHike
FROM customer_churn
WHERE MaritalStatus = 'Single'
  AND PreferredLoginDevice = 'Mobile Phone';
  
  USE ecomm;

-- 7. Average number of devices registered among customers who used UPI as their preferred payment mode
SELECT 
    ROUND(AVG(NumberOfDeviceRegistered), 2) AS AvgDevicesRegistered
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';

-- 8. City tier with the highest number of customers
SELECT 
    CityTier,
    COUNT(*) AS TotalCustomers
FROM customer_churn
GROUP BY CityTier
ORDER BY TotalCustomers DESC
LIMIT 1;

-- 9. Gender that utilized the highest number of coupons
SELECT 
    Gender,
    SUM(CouponUsed) AS TotalCouponsUsed
FROM customer_churn
GROUP BY Gender
ORDER BY TotalCouponsUsed DESC
LIMIT 1;

-- 10. Number of customers and maximum hours spent on the app in each preferred order category
SELECT 
    `Preferred OrderCat`,
    COUNT(*) AS CustomerCount,
    MAX(HoursSpentOnApp) AS MaxHoursSpentOnApp
FROM customer_churn
GROUP BY `Preferred OrderCat`;

-- 11. Total order count for customers who prefer using credit cards and have the maximum satisfaction score
SELECT 
    SUM(OrderCount) AS TotalOrderCount
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
  AND SatisfactionScore = (SELECT MAX(SatisfactionScore) FROM customer_churn);

-- 12. Average satisfaction score of customers who have complained
SELECT 
    ROUND(AVG(SatisfactionScore), 2) AS AvgSatisfactionScore
FROM customer_churn
WHERE ComplaintReceived = 'Yes';

USE ecomm;

-- 13. Preferred order category among customers who used more than 5 coupons
SELECT DISTINCT `Preferred OrderCat`
FROM customer_churn
WHERE CouponUsed > 5;

-- 14. Top 3 preferred order categories with highest average cashback amount
SELECT 
    `Preferred OrderCat`,
    ROUND(AVG(CashbackAmount), 2) AS AvgCashbackAmount
FROM customer_churn
GROUP BY `Preferred OrderCat`
ORDER BY AvgCashbackAmount DESC
LIMIT 3;

-- 15. Preferred payment modes of customers whose average tenure is 10 months and have placed more than 500 orders
SELECT 
    PreferredPaymentMode,
    ROUND(AVG(Tenure), 2) AS AvgTenure,
    SUM(OrderCount) AS TotalOrders
FROM customer_churn
GROUP BY PreferredPaymentMode
HAVING ROUND(AVG(Tenure)) = 10
   AND SUM(OrderCount) > 500;

-- 16. Distance categories and churn status breakdown
SELECT 
    CASE 
        WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10 THEN 'Close Distance'
        WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END AS DistanceCategory,
    ChurnStatus,
    COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus
ORDER BY DistanceCategory, ChurnStatus;

-- 17. Married customers in City Tier-1 with order count > average order count of all customers
SELECT *
FROM customer_churn
WHERE MaritalStatus = 'Married'
  AND CityTier = 1
  AND OrderCount > (SELECT AVG(OrderCount) FROM customer_churn);
  
  USE ecomm;

DROP TABLE IF EXISTS customer_returns;

CREATE TABLE customer_returns (
    ReturnID INT PRIMARY KEY,
    CustomerID INT,
    ReturnDate DATE,
    RefundAmount INT
);

INSERT INTO customer_returns (ReturnID, CustomerID, ReturnDate, RefundAmount) VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);

SELECT 
    r.ReturnID,
    r.ReturnDate,
    r.RefundAmount,
    c.*
FROM customer_returns r
INNER JOIN customer_churn c
    ON r.CustomerID = c.CustomerID
WHERE c.ChurnStatus = 'Churned'
  AND c.ComplaintReceived = 'Yes';