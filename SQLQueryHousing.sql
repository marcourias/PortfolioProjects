SELECT *
FROM PortfolioProject..NashvilleHousing

-- Agregar una columna que cambie Formato de fecha (Día/Tiempo) a Día -Columna SaleDate
-- Add a column that changes date format (day/time) to Day - SaleDate Column



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConvertido Date;

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConvertido = CONVERT(Date, SaleDate)


SELECT SaleDateConvertido
FROM PortfolioProject.dbo.NashvilleHousing


-- Domicilio de las propiedades / Properties addresses
-- Observación: 29 propiedades no tienen domicilio (aunque se trata de un dato fundamental). Podemos llenarlo con la columna "Owner Address"
-- Note: 29 properties have no address (even when is a very important data for this dataset). We can fill it using another column; "Owner Address".
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is Null
ORDER BY ParcelID

-- Primero unimos la tabla con sí misma / First we Join the table to itself.
-- Then we complete the missing data taking data from OwnersAddress column

-- Uniendo la tabla a sí misma y revisando campos vacíos
-- Joining the table to itself and checking empty columns
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

-- Joining data
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null


-- DIVIDIR EL DOMICILIO EN COLUMNAS SEPARADAS (DIRECCIÓN, CIUDAD, ESTADO)
-- DIVIDING ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) as City,
CHARINDEX(',',PropertyAddress) as PosiciónComa
FROM PortfolioProject.dbo.NashvilleHousing

-- Crear dos columnas para agregar Dirección y Ciudad
-- Creating two clumns for Address(split) and City

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add Ciudad nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET Ciudad = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress))


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add Domicilio nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET Domicilio = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


-- Comprobar que se agregaron las columnas al final de la tabla
-- Checking that the columns were added at the end of the table

Select *
From PortfolioProject.dbo.NashvilleHousing

-- Utilizando PARSING para separar una dirección (OwnerAddress)
-- Using PARSING to split an address (Owners Address)


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

-- Reemplazar coma por un punto para utilizar PARSING para separar el domicilio
-- Replacing comma with a period to use PARSING to split address
Select
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From PortfolioProject.dbo.NashvilleHousing


-- Agregando columna con el domicilio
-- Adding a column with just address

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add DomicilioParsing nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET DomicilioParsing = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
From PortfolioProject.dbo.NashvilleHousing


-- Agregando columna con la ciudad
-- Adding a column with city only

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add CityParsing nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET CityParsing = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
From PortfolioProject.dbo.NashvilleHousing

-- Agregando columna con estado
-- Adding a column with state only

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add StateParsing nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET StateParsing = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

-- Revisando los cambios en la tabla:
-- Checking changes to the table:
SELECT DomicilioParsing, CityParsing,StateParsing
FROM PortfolioProject.dbo.NashvilleHousing

-- Separamos satisfactoriamente los datos de una sola columna a tres para obtener: domicilio, ciudad y estado
-- We Successfully split one column into three to obtain address, city and state.


-- Cambiemos valores que indican "Y" y "N", a "Yes" y "No". En columna "Sold as Vacant"
-- Let's change values "Y", "N" to "Yes" and "No". SoldAsVacant Column

-- First we verify what's the issue with this column:

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Then, we try the substitution of the values (We're just selecting)

SELECT SoldAsVacant,
CASE 
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY 1


-- Now that we are sure that the substitution is correct, we update the table

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = 
	CASE 
		When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END

-- Finally we check the column was correctly updated :

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2




-- EJEMPLO DE ELIMINAR COLUMNAS
-- SAMPLE OF REMOVING COLUMNS

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
