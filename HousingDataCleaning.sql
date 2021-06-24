--Data Cleaning NashvilleHousing

SELECT * 
FROM PortfolioProject..NashvilleHousing;

------------------------------------------------------------------------------------------------------------------------------------------------

--Standaedize DATE format

SELECT SaleDate ,convert(date,SaleDate)
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate);

SELECT SaleDateConverted ,convert(date,SaleDate)
FROM PortfolioProject..NashvilleHousing;

------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Missing Property Address Data

SELECT PropertyAddress ,NH.*
FROM PortfolioProject..NashvilleHousing NH
WHERE PropertyAddress is null;

SELECT PropertyAddress ,NH.*
FROM PortfolioProject..NashvilleHousing NH
ORDER BY ParcelID;

/*
Populating the missing address with the address in same parcel id
*/
SELECT NHa.ParcelID,NHa.PropertyAddress,NHb.ParcelID,NHb.PropertyAddress, ISNULL(NHa.propertyAddress,NHb.PropertyAddress) AS PopulatedAddress
FROM PortfolioProject..NashvilleHousing NHa
JOIN PortfolioProject..NashvilleHousing NHb
	ON NHa.ParcelID = NHb.ParcelID
	AND NHa.[UniqueID ]<>NHb.[UniqueID ]
WHERE NHa.PropertyAddress is Null
ORDER BY NHA.ParcelID;

UPDATE NHa
SET PropertyAddress = ISNULL(NHa.propertyAddress,NHb.PropertyAddress)
FROM PortfolioProject..NashvilleHousing NHa
JOIN PortfolioProject..NashvilleHousing NHb
	ON NHa.ParcelID = NHb.ParcelID
	AND NHa.[UniqueID ]<>NHb.[UniqueID ]
WHERE NHa.PropertyAddress is Null;

------------------------------------------------------------------------------------------------------------------------------------------------
--Breaking Out Address into Seprate Columns (Adress,City,State)
/*
Property Address
*/

SELECT PropertyAddress 
FROM PortfolioProject..NashvilleHousing;


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)AS Adress,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCiy NVARCHAR(255);


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
	PropertySplitCiy = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

SELECT * 
FROM PortfolioProject..NashvilleHousing;

/*
Property Address
*/

SELECT OwnerAddress 
FROM PortfolioProject..NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCiy NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) ,
	OwnerSplitCiy = PARSENAME(REPLACE(OwnerAddress,',','.'),2) ,
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 


------------------------------------------------------------------------------------------------------------------------------------------------
--Changing Y and N as Yes and No in Sold as Vacent field to keep on in same format

SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y'THEN 'Yes'
		 WHEN SoldAsVacant = 'N'THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y'THEN 'Yes'
		 WHEN SoldAsVacant = 'N'THEN 'No'
		 ELSE SoldAsVacant
		 END

------------------------------------------------------------------------------------------------------------------------------------------------
--REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
	)Row_num
FROM PortfolioProject..NashvilleHousing
)
Select * 
From RowNumCTE
WHERE row_num >1
ORDER BY propertyAddress

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
	)Row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE 
From RowNumCTE
WHERE row_num >1
------------------------------------------------------------------------------------------------------------------------------------------------
--DELETE Unused Columns
SELECT * 
FROM PortfolioProject..NashvilleHousing;


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate
------------------------------------------------------------------------------------------------------------------------------------------------