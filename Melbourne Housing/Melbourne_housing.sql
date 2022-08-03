-- NOTES:
-- METHOD abbreviation meaning:
--S - property sold;
--SP - property sold prior;
--PI - property passed in;
--PN - sold prior not disclosed;
--SN - sold not disclosed;
--NB - no bid;
--VB - vendor bid;
--W - withdrawn prior to auction;
--SA - sold after auction;
--SS - sold after auction price not disclosed.
--N/A - price or highest bid not available

-- Type abbreviation meaning:
--br - bedroom(s);
--h - house,cottage,villa, semi,terrace;
--u - unit, duplex;
--t - townhouse;
--dev site - development site;
--o res - other residential.

SELECT *
FROM SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$

-- CLEANING DATA
-- Change the abbreviation from housing type colums to something more understandable
UPDATE SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$
SET Type = CASE Type
WHEN 'u' THEN 'unit'
WHEN 't' THEN 'townhouse'
WHEN 'h' THEN 'house'
WHEN 'br' THEN 'bedrooms'
WHEN 'dev site' THEN 'development site'
WHEN 'o res' THEN 'other'
END

SELECT DISTINCT Type
FROM SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$

-- Change the abbreviation from selling method colums to something more understandable
UPDATE SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$
SET Method = CASE Method
WHEN 's' THEN 'sold'
WHEN 'sp' THEN 'sold prior'
WHEN 'pi' THEN 'passed in'
WHEN 'pn' THEN 'sold prior not disclosed'
WHEN 'sn' THEN 'sold not disclosed'
WHEN 'vb' THEN 'vendor bid'
WHEN 'w' THEN 'withdraw from auction'
WHEN 'sa' THEN 'sold after auction'
WHEN 'ss' THEN 'sold after auction not disclosed'
END

SELECT DISTINCT Method
FROM SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$

--Change the date data type from datetime to date
ALTER TABLE SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$
ALTER COLUMN Date date

--DATA ANALYSIS
--Looking at average price for different suburb
SELECT *
FROM SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$

SELECT	Suburb, 
		rooms, 
		ROUND(AVG(Price),-3) AS avg_price
FROM SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$
WHERE type = 'house'
GROUP BY Suburb, rooms
ORDER BY 1,2

--Looking at which 3 rooms or higher houses that sold higher than average price.
SELECT	suburb, 
		rooms, 
		Address, 
		Price,
		Date,
		AVG(price) OVER (Partition BY suburb, rooms) AS avg_price
FROM SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$
WHERE type = 'house' AND rooms >= 3
ORDER BY 1, 2, 4 DESC

WITH avgprice AS(
SELECT	suburb, 
		rooms, 
		Address, 
		Price,
		Date,
		AVG(price) OVER (Partition BY suburb, rooms) AS avg_price
FROM SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$
WHERE type = 'house' AND rooms >= 3
)
SELECT *
FROM avgprice