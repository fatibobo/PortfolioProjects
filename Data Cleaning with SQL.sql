/*

Cleaning Data in SQL Queries
The Data I'm working with is the Nashiville Housing Data

*/

Select *
From PortfolioProject.dbo.NashvilleHousing

------------------------------------

-- Standardize Date Format

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)


Select SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing




------------------------------------

-- Populate Property Address data

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null -- 29 rows are null

-- This code is going to be used to populate the null rows
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


-----------------------------------

--Breaking out Address into Individual Columns (Address, City, State)


-- Property Address

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
From PortfolioProject.dbo.NashvilleHousing


Alter TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Owner Address (this time I am using PARSENAME instead of SUBSTRING)

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), --Parsename only recorgnises period '.' as delimiter, hence i decided to replace ',' with '.'
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing


Alter TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


Alter TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


----------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' column

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2



Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'NO'
END
From PortfolioProject.dbo.NashvilleHousing
where SoldAsVacant = 'Y' or SoldAsVacant = 'N'


Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'NO'
END


-----------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY	ParcelID
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)

DELETE
From PortfolioProject.dbo.NashvilleHousing
Where row_num > 1



----------------------------------

--Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProject.dbo.NashvilleHousing