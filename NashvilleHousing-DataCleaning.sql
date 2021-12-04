/*
Cleaning Data in SQL Queries
*/


Select *
From NashvilleHousing..AllData



-- 1. Standardizing Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From NashvilleHousing..AllData
Update AllData
SET SaleDate = CONVERT(Date,SaleDate)




-- 2. Populate Property Address data

Select *
From NashvilleHousing..AllData
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing..AllData a
JOIN NashvilleHousing..AllData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing..AllData a
JOIN NashvilleHousing..AllData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null





-- 3. Splitting Address into Individual Columns (Address, City, State)


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From NashvilleHousing..AllData


ALTER TABLE AllData
Add PropertySplitAddress Nvarchar(255);

Update AllData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE AllData
Add PropertySplitCity Nvarchar(255);

Update AllData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From NashvilleHousing..AllData


Select OwnerAddress
From NashvilleHousing..AllData


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing..AllData



ALTER TABLE AllData
Add OwnerSplitAddress Nvarchar(255);

Update AllData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE AllData
Add OwnerSplitCity Nvarchar(255);

Update AllData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE AllData
Add OwnerSplitState Nvarchar(255);

Update AllData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From NashvilleHousing..AllData




-- 4. Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing..AllData
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing..AllData


Update AllData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




-- 5. Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing..AllData
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From NashvilleHousing..AllData





-- 6. Delete Unused Columns



Select *
From NashvilleHousing..AllData


ALTER TABLE NashvilleHousing..AllData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate