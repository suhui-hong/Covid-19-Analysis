SELECT *
FROM PortfolioProject..covid_deaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..covid_vaccinations
--ORDER BY 3,4

--Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths
ORDER BY 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE location like'%states%'
ORDER BY 1,2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, Population, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..covid_deaths
--WHERE location like'%germany%'
ORDER BY 1,2


-- Looking at Countries with highest infection rate compeared to population
SELECT Location, MAX(total_cases) AS HighestInfectionCount, Population, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..covid_deaths
GROUP BY location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing countries with hightest death count per population
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Let's break things down by continent
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Showing continents with the hightest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers by date
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Global numbers across the world
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at total population vs vaccination
-- JOIN both table
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
	(continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vacciatnions numeric,
	RollingPeopleVaccinated numeric
	)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating VIEW to store data for visuaalisations
CREATE VIEW v_PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
 dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null



SELECT * 
FROM v_PercentPopulationVaccinated

