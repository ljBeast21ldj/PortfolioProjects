-- Cleaned the Data in SQL

SELECT *
FROM [Portfolio Projects].dbo.NashvilleHousing

-- Standardized Date Format

SELECT /*SaleDate,*/ CONVERT(Date,SaleDate)
FROM [Portfolio Projects].dbo.NashvilleHousing

-- Making sure the Dates are formatted correctly yyyy-mm-dd
ALTER TABLE [Portfolio Projects].dbo.NashvilleHousing
ALTER COLUMN SaleDate DATE
GO

-- Observe the updated Sales date column
SELECT SaleDate
FROM [Portfolio Projects].dbo.NashvilleHousing

-- Populated the Property Address data

SELECT PropertyAddress
FROM [Portfolio Projects].dbo.NashvilleHousing
WHERE PropertyAddress is null

SELECT *
FROM [Portfolio Projects].dbo.NashvilleHousing
ORDER BY ParcelID

-- Self join the table to itself to inspect the UniqueID, ParcelID and PropertyAddress for duplicates
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Projects].dbo.NashvilleHousing a
JOIN [Portfolio Projects].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

-- Update the table so that the Property address with NULL values is populated
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Projects].dbo.NashvilleHousing a
JOIN [Portfolio Projects].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


-- Separating Addresses into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM [Portfolio Projects].dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM [Portfolio Projects].dbo.NashvilleHousing

-- Adds the address to the table
ALTER TABLE [Portfolio Projects].dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

-- Updates the table to set the substring to show only the street address
UPDATE [Portfolio Projects].dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1)

-- Adds the City to the table
ALTER TABLE [Portfolio Projects].dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

-- Updates the table to set the Cities to be in their own column
UPDATE [Portfolio Projects].dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))




-- Separate the Owner's address in different columns (address, city, state)

SELECT OwnerAddress
FROM [Portfolio Projects].dbo.NashvilleHousing

-- Use Parsename instead of substring for the owners address
-- Replace commas with periods
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM [Portfolio Projects].dbo.NashvilleHousing

-- Updating the table to with the new separated columns

ALTER TABLE [Portfolio Projects].dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

-- Updates the table to set the owner's street address in a column
UPDATE [Portfolio Projects].dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE [Portfolio Projects].dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

-- Updates the table to set the owner's city in a column
UPDATE [Portfolio Projects].dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE [Portfolio Projects].dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

-- Updates the table to set the owner's state in a column
UPDATE [Portfolio Projects].dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)



/* 

For the SoldAsVacant column I will clean the data by changing the
'Y' and 'N' to 'Yes' or 'No'.
*/
 -- count how many time each type appears 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Projects].dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
, CASE SoldAsVacant 
	WHEN 'Y' THEN 'Yes'	
	WHEN 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [Portfolio Projects].dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END
	



-- Removed Duplicates

/* This scenario calls for the removal of duplicates as approved by the client/stakeholders
   It is not standard practice to remove or delete data from a database */

-- I'm only writing a CTE(Common Table Expression) to find the duplicates for this project, if any


WITH RowNumCTE AS(
SELECT *,ROW_NUMBER() OVER(
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID
) row_num

FROM [Portfolio Projects].dbo.NashvilleHousing
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

/*

SELECT *
FROM [Portfolio Projects].dbo.NashvilleHousing

ALTER TABLE [Portfolio Projects].dbo.Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

*/





		
