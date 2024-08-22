-- I'm going to use this project to practise datacleaning with sql 

-- let's look at my data
Select Top 10*
From NashvilleHousing

-- Change Date Format, We will create another column where we will put the standard date that we want

Select SaleDateConverted, Convert (Date, SaleDate)
From NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)


-- Populate Property Adress data
--We have observed that some properties don't have an address but when we order data by ParcelID we see that the same parcelID have the also the same property adress
--so our null property adress have to be completed by the propertyID of the the same parcelID, that's what we are trying to do.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
	ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a, NashvilleHousing b
Where a.[UniqueID ] <> b.[UniqueID ] And a.ParcelID = b.ParcelID And a.PropertyAddress Is Null
Order by a.ParcelID
 
Update a
Set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a, NashvilleHousing b
Where a.[UniqueID ] <> b.[UniqueID ] And a.ParcelID = b.ParcelID And a.PropertyAddress Is Null

--Work done !!!!

-- Breaking outaddress into individual columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing

Select
	SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+2, LEN(PropertyAddress)) AS City
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress)-1) 

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+2, LEN(PropertyAddress)) 

Select Top 10*
From NashvilleHousing


-- We can do the same thing with owner address but we will another method to train 
-- Let's use parsename

Select Top 10*
From NashvilleHousing


Select OwnerAddress
From NashvilleHousing


Select 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From NashvilleHousing

      ----now let's add these 3 tables

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select Top 10*
From NashvilleHousing

--- Now we are going to make SoldAsVacant more clear ( we see both 'yes' and 'y' or 'no' an 'n' )

Select Distinct SoldAsVacant, Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
	CASE
		When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
	END 
From NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = CASE
		When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
	END 

-- Perfect

--Remove Duplicates

With RowNumCTE AS
(
Select *, 
	ROW_NUMBER() Over (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
From NashvilleHousing
--Order by ParcelID
)

--DELETE
Select *
From RowNumCTE
Where row_num > 1

-- Awesome! it works, i delete them and afterward, i select and it was nothing left (just for remember..)


---- Delete Unused columns

Select Top 10*
From NashvilleHousing

Alter Table NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousing
DROP COLUMN SaleDate