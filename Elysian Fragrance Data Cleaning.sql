--Bulk import of messydataset into the database for Cleaning and Expository Analysis

CREATE TABLE Elysian (
CustomerID VARCHAR(20),
SalesID	VARCHAR(20),
ProductName VARCHAR(20),
Sentiment VARCHAR(20),
Category VARCHAR(20),
UserType VARCHAR(20),
Gender	VARCHAR(20),
Age	INT,
Price DECIMAL(10, 4),
CostPrice DECIMAL(10,4),
Quantity	INT,
PaymentMethod VARCHAR(20),
City VARCHAR(20),
Country	VARCHAR(20),
BottleSize VARCHAR(15),
Discount DECIMAL(10,4),
PurchaseDate VARCHAR(20),
Rating	VARCHAR(20),
OilContentPercentage VARCHAR(20)
)



BULK INSERT Elysian
FROM 'C:\Users\HP\Downloads\messy_dataset.csv' --specify the path of where your messy data is, remove mine and put yours
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
	FIRSTROW = 2 --skip the first row header
);
 SELECT* FROM Elysian

--BACKING UP DATABASE;

BACKUP DATABASE MyDatabaseNAME
TO Disk = 'C:\SQL Backups/MyClassworkdatabaseBackup.bak';--Specify the filepath you would want to backup to and use .bak as file format



SELECT* FROM Elysian



-- Replacing 'null' in column 'customerID' 

SELECT ISNULL(CustomerID, 'NO-ID')
FROM Elysian

BEGIN TRANSACTION 
UPDATE Elysian
SET CustomerID = ISNULL(CustomerID, 'NO-ID')
COMMIT



--Trimming column 'ProductName' to remove white spaces

SELECT TRIM (ProductName)
FROM Elysian

BEGIN TRANSACTION
    UPDATE  Elysian
    SET ProductName = TRIM (ProductName)
    COMMIT



--Replacing NULL with 'product unknown' in productName Column 

SELECT ISNULL( ProductName, 'Unknown')
FROM Elysian

BEGIN TRANSACTION
     UPDATE  Elysian
     SET ProductName = ISNULL( ProductName, 'Unknown')
COMMIT

	 

--Cleaning sentiment column where all instances of 'Ambivalent' should be changed to 'Neutral'

SELECT 
CASE
    WHEN sentiment = 'Positive' THEN 'Positive'
	WHEN sentiment = 'Negative' THEN 'Negative'
	ELSE 'Neutral'
END
FROM Elysian

BEGIN TRANSACTION 
    UPDATE Elysian
    SET Sentiment = CASE
    WHEN sentiment = 'Positive' THEN 'Positive'
	WHEN sentiment = 'Negative' THEN 'Negative'
	ELSE 'Neutral'
    END
COMMIT

	

--Usertype column should be women, men, unisex ONLY, Hence:

SELECT TRIM( CASE
     WHEN UserType = 'Women' THEN 'Women'
	 WHEN UserType = 'Men' THEN ' Men'
	 WHEN UserType = 'Unisex' THEN 'Unisex'
     WHEN UserType = 'uni' THEN 'Unisex'
	 WHEN UserType = 'man' THEN 'Men'
	 WHEN UserType = 'Woman' THEN 'Women'
	 
END)
 FROM Elysian
	 
	 	
BEGIN TRANSACTION
UPDATE Elysian
         SET UserType =  TRIM( CASE
     WHEN UserType = 'Women' THEN 'Women'
	 WHEN UserType = 'Men' THEN ' Men'
	 WHEN UserType = 'Unisex' THEN 'Unisex'
     WHEN UserType = 'uni' THEN 'Unisex'
	 WHEN UserType = 'man' THEN 'Men'
	 WHEN UserType = 'Woman' THEN 'Women'	 
END)
COMMIT



--Gender Column should be based on the column specification (m/f)

SELECT CASE
		WHEN Gender = 'male' THEN 'm'
		WHEN Gender = 'female' THEN 'f'
		ELSE Gender END 
FROM Elysian

BEGIN TRANSACTION 
UPDATE Elysian
SET Gender = CASE
		WHEN Gender = 'male' THEN 'm'
		WHEN Gender = 'female' THEN 'f'
		ELSE Gender END 
COMMIT


--Replacing customers with age 150 with the mean of the age column without those having age as 150

SELECT REPLACE(Age, '150',
		(SELECT AVG(Age) AS Mean_Age
		 FROM Elysian 
		 WHERE AGE != 150))                 
FROM Elysian

--UPDATE Elysian
BEGIN TRANSACTION 
UPDATE Elysian 
      SET Age = REPLACE(Age, '150',
				(SELECT AVG(Age) AS Mean_Age
				FROM Elysian 
				WHERE AGE != 150))
				COMMIT


--Checked for the number of those having missing values as quantity, 
		--and the number is a lot which must not be dropped,
		--hence, they are replaced with the mean of the column. 
		--Bearing in mind that the quantity column cannot have decimals.  
		--As they are whole rather than half or parts.


SELECT COUNT(*) TOTAL_NULL_COUNT
FROM Elysian
WHERE Quantity IS NULL;

		-- REPLACING THE NULL WITH THE MEAN OF THE COLUMN COZ THE NULLS ARE MANY AND CANNOT BE DISREGARDED

SELECT ISNULL (Quantity, (SELECT AVG(Quantity)
						  FROM Elysian))
FROM Elysian 

		--UPDATE Elysian

BEGIN TRANSACTION 
    UPDATE Elysian
    SET Quantity = ISNULL(Quantity,
						(SELECT AVG(Quantity)
						 FROM Elysian))
						 COMMIT


--CHANGE MISSING VALUES IN COUNTRY COLUMN WITH CITIES row wise, 
		--where country is missing,replace with city value 
		--and drop country and cities, then create LOCATION Column.

SELECT CONCAT(Country,city)
from Elysian
WHERE Country IS NULL

BEGIN TRANSACTION
UPDATE Elysian
SET Country = CONCAT(Country,city)
				from Elysian
				WHERE Country IS NULL
			    COMMIT

--Creating new column 'location'

ALTER TABLE Elysian
ADD Location VARCHAR(50)

BEGIN TRANSACTION
	UPDATE Elysian
	SET location =  Country
COMMIT

--Dropping country and city columns

ALTER TABLE Elysian
DROP COLUMN Country, city


--Standardize purchase date, replace missing date value with  22nd September, 2019 [Glitch Date]
 
SELECT 
	CASE WHEN Purchasedate LIKE '%-%' THEN PurchaseDate
	ELSE  '2019-09-22'
	END 
FROM Elysian

		--UPDATE TABLE

		BEGIN TRANSACTION
		UPDATE Elysian
		SET PurchaseDate =
	               CASE WHEN Purchasedate LIKE '%-%' THEN PurchaseDate
				   ELSE  '2019-09-22'
				   END
		COMMIT

	--Standardizing the purchaseDate column

BEGIN TRANSACTION
		UPDATE Elysian
		SET PurchaseDate = CAST(purchasedate AS Date)
		COMMIT


--The Ratings column should be 1-5, for occurrences of 2022 and 2021 should be replaced with 2 and 1 
		--while for 10 and 12 should be 1 and 2 respectively


SELECT CASE
			WHEN Rating LIKE '%2022%' THEN '2'
			WHEN Rating LIKE '%2021%' THEN '1'
			WHEN Rating = '10'   THEN '1'
			WHEN Rating =  '12'  THEN '2'
			ELSE Rating END
FROM Elysian


--Update Rating column into the table

BEGIN TRANSACTION
UPDATE Elysian
SET Rating = CASE
			WHEN Rating LIKE '%2022%' THEN '2'
			WHEN Rating LIKE '%2021%' THEN '1'
			WHEN Rating = '10'   THEN '1'
			WHEN Rating =  '12'  THEN '2'
			ELSE Rating END
COMMIT


-- Remove the percentage symbols attached to the values in the oil content percentage column

		-- TO remove the NULLS

SELECT ISNULL(OilContentPercentage,'0%')
FROM Elysian

		--update table
BEGIN TRANSACTION
UPDATE Elysian
		SET OilContentPercentage= ISNULL(OilContentPercentage,'0%')
		COMMIT

--To remove the % sign

SELECT REPLACE(OilContentPercentage,'%','')
FROM Elysian

--UPDATE TABLE
BEGIN TRANSACTION 
	UPDATE Elysian
	SET OilContentPercentage = REPLACE(OilContentPercentage,'%','')
	COMMIT

	--Converting OilContent% column to INT
	UPDATE Elysian  
	SET OilContentPercentage= CAST(oilcontentpercentage AS INT)


--Change NULL in Discount column to zero(0)

SELECT ISNULL(Discount, '0')
FROM Elysian

BEGIN TRANSACTION 
UPDATE Elysian
SET Discount = ISNULL (Discount, '0')
COMMIT



