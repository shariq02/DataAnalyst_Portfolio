/*

Cleaning Data in SQL Queries

*/

Select *
From PortFolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDate, SaleDateConverted
From PortFolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

------------------------------------------------------------------------------------------

--Populate Property Address Data

Select *
From PortFolioProject..NashvilleHousing
--WHERE PropertyAddress is Null
Order by ParcelID


Select tab1.ParcelID, tab1.PropertyAddress, tab2.ParcelID, tab2.PropertyAddress, ISNULL(tab1.PropertyAddress, tab2.PropertyAddress)
From PortFolioProject..NashvilleHousing tab1
Join PortFolioProject..NashvilleHousing tab2
	on tab1.ParcelID = tab2.ParcelID
	AND tab1.[UniqueID ] <> tab2.[UniqueID ]
WHERE tab1.PropertyAddress is Null

Update tab1
SET PropertyAddress = ISNULL(tab1.PropertyAddress, tab2.PropertyAddress)
From PortFolioProject..NashvilleHousing tab1
Join PortFolioProject..NashvilleHousing tab2
	on tab1.ParcelID = tab2.ParcelID
	AND tab1.[UniqueID ] <> tab2.[UniqueID ]
WHERE tab1.PropertyAddress is Null

----------------------------------------------------------------------------------------------

--Breaking out Address into individual columns (Address, City, State)

Select PropertyAddress
From PortFolioProject..NashvilleHousing

Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortFolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NvarChar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NvarChar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select PropertyAddress, PropertySplitAddress, PropertySplitCity
From PortFolioProject..NashvilleHousing


Select OwnerAddress
From PortFolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From PortFolioProject..NashvilleHousing
Order by 1 desc

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NvarChar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NvarChar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NvarChar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From PortFolioProject..NashvilleHousing
Order by 1 desc

-----------------------------------------------------------------------------------------

-- Change Y and N to  Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant) as Count
From PortFolioProject..NashvilleHousing
Group By SoldAsVacant
Order by 2

Select SoldAsVacant,
	Case when SoldAsVacant = 'Y' Then 'Yes'
		 when SoldAsVacant = 'N' Then 'No'
		 ELSE SoldAsVacant
		 END
From PortFolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
		 when SoldAsVacant = 'N' Then 'No'
		 ELSE SoldAsVacant
		 END

---------------------------------------------------------------------------------------

-- Remove Duplicates Data

-- First Check for Duplicate Date
WITH RowNumCTE AS (
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
From PortFolioProject..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by ParcelID

-- Remove Data

WITH RowNumCTE AS (
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
From PortFolioProject..NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1

-------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortFolioProject..NashvilleHousing

Alter Table PortFolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

Alter Table PortFolioProject..NashvilleHousing
DROP COLUMN SaleDate