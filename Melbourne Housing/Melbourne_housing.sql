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

SELECT *
FROM SQL_project .. Melbourne_housing_FULL$

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
--Looking at average price of house for different suburb
SELECT *
FROM SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$
WHERE suburb = 'docklands'

SELECT	Suburb, 
		rooms AS bedrooms, 
		ROUND(AVG(Price),-3) AS avg_price
FROM SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$
WHERE type = 'house'
GROUP BY Suburb, rooms
ORDER BY 1,2

--Looking if distance to CBD affect average price of houses
SELECT	Suburb,
		ROUND(AVG(Price),-3) AS avg_price,
		ROUND(AVG(distance),1) AS avg_distance
FROM SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$
WHERE type = 'house' AND price IS NOT NULL
GROUP BY Suburb
ORDER BY 3

--Looking at house address with 3 rooms or higher that sold higher than average price and by how much
--I use left join because the price_less table have more data point.
SELECT	les.suburb, 
		les.rooms AS bedroom,
		ful.bathroom,
		ful.car,
		les.Address, 
		les.Price,
		les.Date,
		AVG(les.price) OVER (Partition BY les.suburb, les.rooms) AS avg_price
FROM SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$ AS les
LEFT JOIN SQL_project..Melbourne_housing_FULL$ AS ful ON les.Address = ful.address
WHERE les.type = 'house' AND les.rooms >= 3
ORDER BY 1, 2, 4 DESC

WITH avgprice AS(
SELECT	les.suburb, 
		les.rooms AS bedroom,
		ful.bathroom,
		ful.car,
		les.Address,
		ful. landsize, 
		les.Price,
		les.Date,
		AVG(les.price) OVER (Partition BY les.suburb, les.rooms) AS avg_price
FROM SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$ AS les
LEFT JOIN SQL_project..Melbourne_housing_FULL$ AS ful ON les.Address = ful.address
WHERE les.type = 'house' AND les.rooms >= 3
)
SELECT Suburb, bedroom,  address, price, ROUND(avg_price,-3) AS avg_price, ROUND(price/ROUND(avg_price,-3), 1) AS 'times higher'
FROM avgprice
WHERE price > avg_price
ORDER BY 6 DESC

--I want to know why the price is higher than average. so I look at the landsize, number of bathrooms and car spaces.
--I created a Table so that I can use visualization tools to find trend.
--I remove all NULL values and landsize = 0
WITH avgprice AS(
SELECT	les.suburb, 
		les.rooms AS bedroom,
		ful.bathroom,
		ful.car,
		les.Address,
		ful. landsize, 
		les.Price,
		les.Date,
		AVG(les.price) OVER (Partition BY les.suburb, les.rooms) AS avg_price
FROM SQL_project .. MELBOURNE_HOUSE_PRICES_LESS$ AS les
LEFT JOIN SQL_project..Melbourne_housing_FULL$ AS ful ON les.Address = ful.address
WHERE les.type = 'house' AND les.rooms >= 3
)
SELECT Suburb, bedroom, bathroom, car, landsize, price, ROUND(avg_price,-3) AS avg_price, ROUND(price/ROUND(avg_price,-3), 1) AS 'times higher'
FROM avgprice
WHERE price IS NOT NULL AND car IS NOT NULL AND landsize IS NOT NULL AND landsize <> 0
ORDER BY 1, 8

