
--Data cleaning in SQL

--USE Damilare_SQL
	SELECT * 
	FROM Nashville;

--since Property_Address is together with the ParcelID,
--we populate NULL Property_Address with those that have address in the ParcelID
--we joined Nashville table to itself to make this plossible

SELECT Na.ParcelID, Na.PropertyAddress, Nb.ParcelID, Nb.PropertyAddress,
	   ISNULL(Na.PropertyAddress, Nb.PropertyAddress)
FROM Nashville Na
JOIN Nashville Nb
	ON Na.ParcelID = Nb.ParcelID
	AND Na.UniqueID != Nb.UniqueID
WHERE Na.PropertyAddress IS NULL ;

--update Nashville Table

BEGIN TRANSACTION
UPDATE Na 
		SET PropertyAddress =  ISNULL(Na.PropertyAddress, Nb.PropertyAddress)
		FROM Nashville Na
		JOIN Nashville Nb
		ON Na.ParcelID = Nb.ParcelID
		AND Na.UniqueID != Nb.UniqueID
		WHERE Na.PropertyAddress IS NULL
COMMIT;

--Splitting Property Address into several column( Address, City)
		--we use Substring function for this

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as city
FROM Nashville;

	ALTER TABLE Nashville 
	ADD  Address VARCHAR(230);

	ALTER TABLE Nashville 
	ADD  City VARCHAR(230);
 

UPDATE Nashville 
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


UPDATE Nashville 
SET city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));


--Seperate OwnersAddres into several columns ( Address, City, State)

--SELECT OwnerAddress
--FROM Nashville;

SELECT 
		PARSENAME (REPLACE(ownerAddress, ',', '.'), 3) AS ownerAdd,
		PARSENAME (REPLACE(ownerAddress, ',', '.'), 2) AS ownerCity,
		PARSENAME (REPLACE(ownerAddress, ',', '.'), 1) AS ownerState
FROM Nashville;

ALTER TABLE Nashville 
	ADD  ownerAdd VARCHAR(230);

ALTER TABLE Nashville 
	ADD  ownerCity VARCHAR(230);

ALTER TABLE Nashville 
	ADD  ownerState VARCHAR(230);

UPDATE Nashville 
SET ownerAdd = PARSENAME (REPLACE(ownerAddress, ',', '.'), 3);

UPDATE Nashville 
SET ownerCity = PARSENAME (REPLACE(ownerAddress, ',', '.'), 2);

UPDATE Nashville 
SET ownerState = PARSENAME (REPLACE(ownerAddress, ',', '.'), 1);

--Changing 1 and 0 to  NO and YES in SoldasVacant column respectively

		SELECT DISTINCT (soldasvacant), COUNT(soldasvacant)
		FROM Nashville
		GROUP BY soldasvacant
		ORDER BY 1,2;

ALTER TABLE Nashville
ALTER COLUMN SoldasVacant Varchar (250)

SELECT CASE
			WHEN SoldAsVacant = 1 THEN 'Yes'
			WHEN SoldAsVacant = 0 THEN 'No'
			ELSE SoldAsVacant
			END
FROM Nashville;


UPDATE Nashville 
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 1 THEN 'Yes'
		WHEN SoldAsVacant = 0 THEN 'No'
		ELSE SoldAsVacant
		END;

select* from Nashville;

--Removing Duplicate Values

WITH row_numCTE AS(
SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 Saledate,
					 legalReference
					 ORDER BY 
						UniqueID
						) row_num

FROM Nashville );
--ORDER BY ParcelID

	DELETE  
	FROM row_numCTE
	where row_num > 1;

WITH row_numCTE AS(
SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 Saledate,
					 legalReference
					 ORDER BY 
						UniqueID
						) row_num

FROM Nashville )
--ORDER BY ParcelID
	SELECT*  
	FROM row_numCTE
	where row_num > 1;

--Removing unused and irrelevant Columns 

SELECT * INTO cleaned_Nashville_dataset
FROM Nashville ;

ALTER TABLE cleaned_Nashville_dataset
DROP COLUMN PropertyAddress,owneraddress,taxdistrict;

CREATE VIEW cleaned_nashville AS
SELECT*
FROM cleaned_Nashville_dataset;

SELECT * FROM cleaned_nashville;
