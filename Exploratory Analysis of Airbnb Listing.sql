--**EXAMINE THE DATASET**

	SELECT* FROM Reviews
	SELECT* FROM Listings


--**COPY THE TABLES FOR DATA SAFETY**
	SELECT* 
	INTO reviews_copy
	FROM Reviews
----
	SELECT* 
	INTO listing_copy
	FROM Listings

--EXPLORE THE DATASET FOR  UNIQUE, MISSING, AND INCONSISTENT VALUES IN THE DATASET

	SELECT COUNT(DISTINCT host_id) AS total_Host,
		   COUNT(DISTINCT district) AS Total_district,
		   COUNT(DISTINCT room_type) AS Total_room_type,
		   COUNT(DISTINCT Property_type) AS Total_property_type,
		   COUNT(DISTINCT bedrooms ) AS bedrooms_count, 
		   COUNT(DISTINCT accommodates) AS Accomodate_count
	FROM Listings
	

	--get the total  number of locations for every host with properties listed on Airbnb

		SELECT COUNT (DISTINCT host_location)
		FROM Listings
		

	--Get Unique details for major columns in the dataset

	SELECT DISTINCT city FROM Listings
	SELECT Distinct neighbourhood from Listings
	SELECT DISTINCT room_type FROM Listings
	SELECT DISTINCT instant_bookable FROM Listings
	SELECT DISTINCT Season FROM reviews
	SELECT DISTINCT review_year FROM Reviews
	
	
-- TRIM FOR EXCESSIVE SPACES AND INCONSISTENCIES 

	BEGIN TRANSACTION
	UPDATE Listings
	SET name = TRIM(BOTH '!''-''.''"''*''#''/''@''()'FROM name) FROM Listings
	COMMIT

--Replacing Null Values
	BEGIN TRANSACTION 
	UPDATE Listings
	SET bedrooms=  ISNULL ( bedrooms, 0) from listings 
	COMMIT
 
	BEGIN TRANSACTION
		UPDATE Listings
		SET review_scores_rating=
		CASE 
		WHEN review_scores_rating IS NULL THEN 0 ELSE review_scores_rating END FROM Listings	
		COMMIT
		
	BEGIN TRANSACTION
		UPDATE Listings
		SET review_scores_accuracy=
		CASE 
		WHEN review_scores_accuracy IS NULL THEN 0 
		ELSE review_scores_accuracy END FROM Listings
		COMMIT


	BEGIN TRANSACTION 
		UPDATE Listings
		SET review_scores_cleanliness= 
		CASE 
		WHEN review_scores_cleanliness IS NULL THEN 0 
		ELSE review_scores_cleanliness END FROM Listings
		COMMIT
	BEGIN TRANSACTION 
		UPDATE Listings
		SET review_scores_checkin=
		CASE 
		WHEN review_scores_checkin IS NULL THEN 0 
		ELSE review_scores_checkin END FROM Listings
		COMMIT

	BEGIN TRANSACTION
		UPDATE Listings
		SET review_scores_communication=
		CASE 
		WHEN review_scores_communication IS NULL THEN 0 
		ELSE review_scores_communication END FROM Listings
		COMMIT

	BEGIN TRANSACTION 
		UPDATE Listings
		SET review_scores_location= 
		CASE 
		WHEN review_scores_location IS NULL THEN 0 
		ELSE review_scores_location END FROM Listings
		COMMIT

	BEGIN TRANSACTION
		UPDATE Listings
		SET review_scores_value=
						CASE 
						WHEN review_scores_value IS NULL THEN 0 
						ELSE review_scores_value END FROM Listings
						COMMIT
		

	BEGIN TRANSACTION
		UPDATE Listings
		SET district=CASE 
					WHEN district IS NULL THEN 'Unknown'
					ELSE district END
					FROM Listings
					COMMIT

	--Change 'Unkown' to 'Others' in District column 
		BEGIN TRANSACTION
		UPDATE Listings
		SET District= CASE 
				  WHEN District = 'unknown' THEN 'Others' 
				  ELSE district END
				  FROM Listings		
                  COMMIT

-- Split the review date into months, year and seasons 

		ALTER TABLE Reviews
		ADD review_year INT

	BEGIN TRANSACTION 
	UPDATE Reviews
	SET Review_year =  YEAR(date)
	FROM Reviews
	COMMIT
--------------	
		ALTER TABLE Reviews
		ADD review_month INT

	BEGIN TRANSACTION
	UPDATE Reviews
	SET review_month = MONTH(date)
	FROM Reviews
	COMMIT
------------
		ALTER TABLE Reviews
		ADD Season VARCHAR(20)

	BEGIN TRANSACTION
	UPDATE Reviews
	SET season = CASE
		WHEN review_month IN (1,2,12) THEN 'Winter'
		WHEN review_month IN (6,7,8) THEN 'Summer'
		WHEN review_month IN (3,4,5) THEN 'Spring' 
		ELSE 'Autum' END 
	FROM Reviews
	COMMIT



--ANALYSIING DATA FOR INSIGHTS 
			

--Total value of the listings in the Airbnb

SELECT SUM(Price) Total_value
FROM listings

--Total value of listings in the cities on the airbnb 

	SELECT city, SUM(Price) AS Total_value
	FROM Listings
	GROUP BY city 

--Total number of listings on the Airbnb

	SELECT COUNT (DISTINCT Listing_ID) Total_listing
	FROM Listings 

--Total number of host on the Airbnb

	SELECT  COUNT ( DISTINCT Host_id) Host_Total
	FROM Listings 

--Total numbers of host in each city

	SELECT City, COUNT(DISTINCT Host_id) AS Total_host
	FROM Listings 
	GROUP BY city

----Get the accumulation of listings made by every host on the Airbnb 

	SELECT city, SUM(host_total_listings_count) AS Total_host_count
	FROM Listings 
	GROUP BY City 

-- Average Price of the Airbnb listings 

	SELECT AVG(price) AS Averag_Price
	FROM Listings 


--Average Price of listing per night in the cities

	SELECT City, AVG(Price) AS Average_Price
	FROM Listings 
	GROUP BY city 

--Total numbers of reviews received in each city on Airbnb

	SELECT L.city, COUNT(DISTINCT R.review_id) AS review_count
	FROM Listings L
	join Reviews R
	ON L.listing_id = R.listing_id
	GROUP BY L.city 

-- Average price by the types of properties listed on Airbnb

	SELECT city,property_type, AVG(price) AS Average_price
	FROM Listings 
	GROUP BY city,property_type

--Average price  by the rooms categories listed in the city

	SELECT distinct city,room_type, Avg(Price) AS Average_price
	FROM Listings
	GROUP BY city,room_type


-- Get the seasonal price trend in the cities base on the reviews

	SELECT L.city, R.Season, AVG(L.price) AS Average_price
	FROM Listings L
	join Reviews R
	ON L.listing_id = R. listing_id
	GROUP BY L.city,  R.Season


--Lets get the overview of nights a guest can booked and the estimated price

	SELECT  city, minimum_nights , maximum_nights, (minimum_nights + maximum_nights)/2 AS average_nights, AVG(price) AS Average_price
	FROM Listings 
	GROUP BY city, minimum_nights , maximum_nights, (minimum_nights + maximum_nights)/2


-- identify the  host city  with location ratings between 5 and 10, and the Price per rating 

	SELECT  city, review_scores_location, AVG(Price) AS Average_price
	FROM  listings 
	WHERE review_scores_location BETWEEN 5 AND 10
	GROUP BY city, review_scores_location
	ORDER BY Average_price DESC


---- check for the top 10 listings with review_acore_accuracy of 5 and above in the cities   

	SELECT TOP 10 listing_id,property_type, COUNT(review_scores_accuracy)
	FROM Listings 
	WHERE review_scores_accuracy >=5
	GROUP BY listing_id, property_type



---- identify host with  review_scores_value, of 5 and above 

 SELECT TOP 10 city, review_scores_value, AVG(price) AS Average_price 
 FROM Listings 
 GROUP BY city, review_scores_value
 ORDER BY   Average_price

--Host acceptance rate by cities 

SELECT  City, host_acceptance_rate, AVG(price) AS Average_price
FROM listings 
GROUP BY city,host_acceptance_rate
HAVING  host_acceptance_rate IS NOT NULL 
ORDER BY Average_price DESC

--Examine the average review score of hosts in the city like Paris and New York; especially during summer and winter

SELECT L.host_id, L.city, R.Season, AVG(L.review_scores_rating) AS Average_ratings
FROM Listings L
JOIN Reviews R
ON L.listing_id = R. listing_id
GROUP BY L.host_id, L.city, R.Season
HAVING city IN ('Paris','New York') AND season IN ('Summer', 'winter')


--Lets check the seasonal overall rating scores for properties listed  

SELECT L.city,L.property_type, R.Season, AVG(L.review_scores_rating) AS Average_Rating
FROM Listings L
JOIN  Reviews R
ON l.listing_id = r.listing_id
GROUP BY l.city, l.district,l.property_type, R.Season
 

--Checking for the city's cleaning review records and identify the ones with averae score and above

	SELECT l.City, l.review_scores_cleanliness, COUNT( review_scores_cleanliness) AS cleanliness_count
	FROM Listings L
	JOIN Reviews R
	ON L.listing_id= R. listing_id
	GROUP BY L.City, l.review_scores_cleanliness
	HAVING review_scores_cleanliness >= 5

---Lets get the properties that can be booked instantly and has the ratings scores of 50 and above

	WITH InstantBookable AS(
	SELECT l.city, l.property_type, L.instant_bookable, R.Season,
		   AVG(L.review_scores_rating) AS Average_rating, AVG(Price) AS Average_price
	FROM Listings L
	JOIN Reviews R
	ON L.listing_id = R.listing_id
	GROUP BY l.city, l.property_type, L.instant_bookable, R.Season
	)

	SELECT *
	FROM InstantBookable
	WHERE Average_rating >=50 and instant_bookable = 1
	ORDER BY Average_rating DESC , Average_price DESC

--Let’s see the listing price of all super host accepting instant booking and has a good rating

WITH superbooking AS (
	SELECT City, Host_is_superhost, instant_bookable, AVG(review_scores_rating) AS Average_rating, 
	COUNT( host_is_superhost) AS superhost_count, AVG(Price) AS Average_price
	FROM listings 
	WHERE host_is_superhost = 1
	GROUP BY city, host_is_superhost, instant_bookable
	)

	SELECT *
	FROM superbooking
	where Average_rating >= 50 AND  instant_bookable = 1 







