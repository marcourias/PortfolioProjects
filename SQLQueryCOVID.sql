Select *
From PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths
--Order by 1,2

--Total de Casos vs Total de Muertes en México
-- Esta es la probabilidad de morir en caso de contraer COVID
--SELECT location as Ubicación, date as Fecha, total_cases as TotaldeCasos, 
--total_deaths as TotaldeMuertes, (total_deaths/total_cases)*100 as PorcentajedeMuertes
--FROM PortfolioProject..CovidDeaths
--WHERE location = 'Mexico'
--Order by 1,2

-- Total de Casos vs Población Total
-- Muestra el porcentaje de la población que ha tenido COVID

SELECT location as Ubicación, date as Fecha,population as Población, 
total_cases as TotaldeCasos, 
(total_cases/population)*100 as PorcentajedeContagios
FROM PortfolioProject..CovidDeaths
WHERE location = 'Mexico'
Order by 1,2

-- Países con mayores tasas de Infección (vs Población)
SELECT location as Ubicación,population as Población, 
MAX(total_cases) as MayorCantidadDeCasos, 
MAX((total_cases/population))*100 as PorcentajeDePoblaciónContagiada
FROM PortfolioProject..CovidDeaths
Group by Location, Population
Order by 4 desc

-- Mostrando los países con la mayor cantidad de Muertes
SELECT location as Ubicación, 
MAX(CAST(total_deaths as int)) as CantidadDeMuertes
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by CantidadDeMuertes desc

-- Comparando Muertes por Continente
SELECT continent as Continente, 
MAX(CAST(total_deaths as int)) as CantidadDeMuertes
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by CantidadDeMuertes desc

-- Números Globales por fecha casos diarios y muertes diarias
SELECT date, SUM(new_cases) as TotaldeCasosDiarios, SUM(CAST(new_deaths as int)) as TotalMuertesDiarias,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as PorcentajedeMuertes
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by date
ORDER by 1,2

-- Números Globales Casos Totales, Muertes Totales y porcentaje de Muertes
SELECT SUM(new_cases) as TotaldeCasosDiarios, SUM(CAST(new_deaths as int)) as TotalMuertesDiarias,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as PorcentajedeMuertes
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER by 1,2


-- Total de población y Vacunación diaria
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as SumatoriadeVacunas
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3

-- Usando CTE para comparar Total de población y Vacunación diaria 
WITH PopvsVac (Continent,location, date, Population, new_vaccionations, SumatoriadeVacunas)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as SumatoriadeVacunas
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
)
Select *, (SumatoriadeVacunas/Population)*100 as 'RelaciónVacunas-Población'
From PopvsVac

-- Usando Tabla temporal para comparar vacunas y población
DROP Table if exists #PorcentajePoblaciónVacunada
Create Table #PorcentajePoblaciónVacunada
(
Continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccionations numeric,
SumatoriadeVacunas numeric
)
Insert into #PorcentajePoblaciónVacunada
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as SumatoriadeVacunas
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

Select *, ((SumatoriadeVacunas/Population)*100)/2 as 'RelaciónVacunas-Población' --Considerando vacunación de 2 dosis/considering 2 dose vaccines
From #PorcentajePoblaciónVacunada

-- Generando vista para almacenar datos para visualización posterior
CREATE View PorcentajePoblaciónVacunada as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as SumatoriadeVacunas
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
