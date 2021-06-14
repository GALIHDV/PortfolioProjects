SELECT*
FROM PortfolioProject..['CovidDeaths$']
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..['CovidVaccination$']
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['CovidDeaths$']
ORDER BY 1,2 

--Looking at Total Cases vs Total Deaths
-- Show what percentage of total death per total cases

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..['CovidDeaths$']
WHERE location = 'Indonesia'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Show what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infection_percentage
FROM PortfolioProject..['CovidDeaths$']
--WHERE location = 'Indonesia'
ORDER BY 1,2 

-- Looking at Countries with Highest Infection Rate Compared to Population
SELECT location, population, MAX(total_cases) as highest_infection, MAX(total_cases/population)*100 AS infection_percentage
FROM PortfolioProject..['CovidDeaths$']
GROUP BY location, population
ORDER BY infection_percentage DESC

--Let's break things down by continent
--Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) as highest_deaths
FROM PortfolioProject..['CovidDeaths$']
WHERE continent is null
GROUP BY continent
ORDER BY highest_deaths DESC

--Global numbers
SELECT SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS int)) AS TotalNewDeaths,SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS NewDeathPercentage
FROM PortfolioProject..['CovidDeaths$']
--WHERE location LIKE  '%states%'
WHERE continent is not null
--GROUP BY date
--ORDER BY 1,2

--Looking at total population vs vaccinations
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) --Fungsi ini akan menciptakan temp table PopvsVac
AS (
SELECT dea.continent, dea.location, dea.date, 
       dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations AS INT)) 
	   OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --Fungsi ini akan melakukan operasi penjumlahan kumulatif dari orang yang sudah divaksinasi berdasarkan lokasi dan tanggal
FROM PortfolioProject..['CovidDeaths$'] dea
JOIN PortfolioProject..['CovidVaccination$'] vac ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeopleVaccinatedPercentage 
FROM PopvsVac



--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, 
       dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations AS INT)) 
	   OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --Fungsi ini akan melakukan operasi penjumlahan kumulatif dari orang yang sudah divaksinasi berdasarkan lokasi dan tanggal
FROM PortfolioProject..['CovidDeaths$'] dea
JOIN PortfolioProject..['CovidVaccination$'] vac ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeopleVaccinatedPercentage 
FROM #PercentPopulationVaccinated



