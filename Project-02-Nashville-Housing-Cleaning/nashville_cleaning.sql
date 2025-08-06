-- Cleaning Data in SQL Queries

SELECT *
FROM PortfolioProject..NashvilleHousing

---------------------------------------Standardize Date Format


SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) -- Not working as we cannot update the data type of a column using update


ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE; -- so this will remove the all time info from that column perm



---------------------------------------Populate Property Address data

SELECT COUNT(*)
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT n1.[UniqueID ], n1.ParcelID, n1.PropertyAddress, n2.PropertyAddress, n2.[UniqueID ], n2.ParcelID
FROM NashvilleHousing n1
JOIN NashvilleHousing n2
	ON n1.ParcelID = n2.ParcelID
	AND n1.[UniqueID ]<> n2.[UniqueID ]-- as we dont want to get the same ones as it would have repeated itself 
WHERE n1.PropertyAddress IS NULL 


-- we can do this in two ways 


UPDATE NashvilleHousing n1
JOIN NashvilleHousing n2
	ON n1.ParcelID = n2.ParcelID
	AND n1.[UniqueID ]<> n2.[UniqueID ]-- as we dont want to get the same ones as it would have repeated itself 
SET n1.PropertyAddress = n2.PropertyAddress
WHERE n1.PropertyAddress IS NULL


-- OR more clearer way


SELECT n1.[UniqueID ], n1.ParcelID, n1.PropertyAddress, n2.PropertyAddress, n2.[UniqueID ], n2.ParcelID, ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM NashvilleHousing n1
JOIN NashvilleHousing n2
	ON n1.ParcelID = n2.ParcelID
	AND n1.[UniqueID ]<> n2.[UniqueID ]-- as we dont want to get the same ones as it would have repeated itself 
WHERE n1.PropertyAddress IS NULL


UPDATE n1
SET PropertyAddress = ISNULL(n1.PropertyAddress, n2.PropertyAddress) -- ISNULL(value, replacement): Returns 'value' if it's NOT NULL; otherwise returns 'replacement'
FROM NashvilleHousing n1
JOIN NashvilleHousing n2
	ON n1.ParcelID = n2.ParcelID
	AND n1.[UniqueID ]<> n2.[UniqueID ]
WHERE n1.PropertyAddress IS NULL


---------------------------------------Breaking out Address into individual Columns (Address, City, State)


SELECT PropertyAddress
FROM NashvilleHousing 


SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) AS Address, -- so basically we going to the comma and then going back 1
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))


SELECT *
FROM NashvilleHousing

-- Now OwnerAddress

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) -- PARSENAME(string, part): Splits a string by dots and returns the specified part (1 = last, 3 = first)
FROM PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerPropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerPropertySplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerPropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerPropertySplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
ADD PropertySplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)




---------------------------------------Change Y and N to Yes and No in "SoldAsVacant" field


SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- We can do it in two way
UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant = 'Y';


UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = 'No'
WHERE SoldAsVacant = 'N';

-- OR
UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = 
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END


---------------------------------------Remove Dublicates
-- Checking for the Dublicates
SELECT ParcelID, SaleDate, PropertyAddress, SalePrice,LegalReference, COUNT(*) AS duplicate_count
FROM PortfolioProject..NashvilleHousing
GROUP BY ParcelID, SaleDate, PropertyAddress, SalePrice,LegalReference
HAVING COUNT(*) > 1; 
 

WITH CTE_dublicates AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY ParcelID, SaleDate, PropertyAddress, SalePrice,LegalReference
      ORDER BY UniqueID
    ) AS row_num
  FROM PortfolioProject..NashvilleHousing
)
SELECT *
FROM CTE_dublicates
WHERE row_num > 1
ORDER BY PropertyAddress


-- Deleting the dublicates
WITH CTE_dublicates AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY ParcelID, SaleDate, PropertyAddress, SalePrice,LegalReference
      ORDER BY UniqueID
    ) AS row_num
  FROM PortfolioProject..NashvilleHousing
)
DELETE 
FROM CTE_dublicates
WHERE row_num > 1



---------------------------------------Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


