-- Cleaned the Data in SQL

SELECT *
FROM [Portfolio Projects].dbo.Nashville_Housing

-- Standardized Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM [Portfolio Projects].dbo.Nashville_Housing

-- Making sure the Dates are formatted correctly yyyy-mm-dd
SELECT SaleDate
FROM [Portfolio Projects].dbo.Nashville_Housing

-- Populated the Property Address data

SELECT PropertyAddress
FROM [Portfolio Projects].dbo.Nashville_Housing
WHERE PropertyAddress is null

SELECT *
FROM [Portfolio Projects].dbo.Nashville_Housing
ORDER BY ParcelID

-- Self join the table to itself to inspect the UniqueID, ParcelID and PropertyAddress for duplicates
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Projects].dbo.Nashville_Housing a
JOIN [Portfolio Projects].dbo.Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

-- Update the table so that the Property address with NULL values is populated
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Projects].dbo.Nashville_Housing a
JOIN [Portfolio Projects].dbo.Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


-- Separating Addresses into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM [Portfolio Projects].dbo.Nashville_Housing


SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM [Portfolio Projects].dbo.Nashville_Housing

-- Adds the address to the table
ALTER TABLE [Portfolio Projects].dbo.Nashville_Housing
ADD PropertySplitAddress NVARCHAR(255);

-- Updates the table to set the substring to show only the street address
UPDATE [Portfolio Projects].dbo.Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1)

-- Adds the City to the table
ALTER TABLE [Portfolio Projects].dbo.Nashville_Housing
ADD PropertySplitCity NVARCHAR(255);

-- Updates the table to set the Cities to be in their own column
UPDATE [Portfolio Projects].dbo.Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))




-- Separate the Owner's address in different columns (address, city, state)

SELECT OwnerAddress
FROM [Portfolio Projects].dbo.Nashville_Housing

-- Use Parsename instead of substring for the owners address
-- Replace commas with periods
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM [Portfolio Projects].dbo.Nashville_Housing

-- Updating the table to with the new separated columns

ALTER TABLE [Portfolio Projects].dbo.Nashville_Housing
ADD OwnerSplitAddress NVARCHAR(255);

-- Updates the table to set the owner's street address in a column
UPDATE [Portfolio Projects].dbo.Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE [Portfolio Projects].dbo.Nashville_Housing
ADD OwnerSplitCity NVARCHAR(255);

-- Updates the table to set the owner's city in a column
UPDATE [Portfolio Projects].dbo.Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE [Portfolio Projects].dbo.Nashville_Housing
ADD OwnerSplitState NVARCHAR(255);

-- Updates the table to set the owner's state in a column
UPDATE [Portfolio Projects].dbo.Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)



/* 

For the SoldAsVacant column I will communicate with the stakeholder(s) 
to get more insight as to why this column is in 0s and 1s so that I can
understand which one represents 'Yes' or 'No' and then clean the data.

*/

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Projects].dbo.Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2

/* 0s appeared 51,802 times and 1s appeared 4,675 times. 
It seems though 0s may represent 'No' while 1s represent
'Yes'.  Once again, the stakeholder would have the final
decision so that I don't alter the data in error.
*/

/*
After communicating with the stakeholder I'm now cleared 
to change the 0s to 'No' and the 1s to 'Yes'
*/

SELECT SoldAsVacant
, CASE SoldAsVacant 
	WHEN 1 THEN 'Yes'	
	WHEN 0 THEN 'No'
	   ELSE CAST(SoldAsVacant AS VARCHAR(3))
	   END
FROM [Portfolio Projects].dbo.Nashville_Housing

-- Altering the table so that it can be updated to 'Yes or 'No'
ALTER TABLE [Portfolio Projects].dbo.Nashville_Housing
ALTER COLUMN SoldAsVacant VARCHAR(3)

-- Updating the table
UPDATE [Portfolio Projects].dbo.Nashville_Housing
SET SoldAsVacant = CASE SoldAsVacant 
	WHEN 1 THEN 'Yes'	
	WHEN 0 THEN 'No'
	   ELSE NULL
END



-- Removed Duplicates

/* This scenario calls for the removal of duplicates as approved by the client/stakeholders
   It is not standard practice to remove or delete data from a database */

-- Writing a CTE(Common Table Expression) to find the duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY ParcelID,
								   PropertyAddress,
								   SalePrice,
								   SaleDate,
								   LegalReference
								   ORDER BY
										UniqueID
										) row_num

FROM [Portfolio Projects].dbo.Nashville_Housing
-- ORDER BY ParcelID
) 
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress





-- Deleting Unused Columns
/* Even though deleting is approved in this scenario in this project, it is not common practice
to delete raw data and shall not be done without approval.
*/


SELECT *
FROM [Portfolio Projects].dbo.Nashville_Housing

ALTER TABLE [Portfolio Projects].dbo.Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


-- Trigger Update





		
