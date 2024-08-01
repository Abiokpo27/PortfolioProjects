-- Portfolio Data Exploration Analysis
-- COVID Data 

SELECT *
FROM PortfolioProject.dbo.CovidMDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations$
--ORDER BY 3,4

-- Select the Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidMDeaths$
WHERE continent is not null
ORDER BY 1,2


-- Showing Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidMDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Location: United States
-- Showing likeklihood of dying if you contract covid in the United States

SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidMDeaths$
WHERE Location LIKE '%states%'
AND continent is not null
ORDER BY 1,2

-- Location: Africa
-- Showing likeklihood of dying if you contract covid in Africa

SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidMDeaths$
WHERE Location LIKE 'Africa'
AND continent is not null
ORDER BY 1,2

-- Showing Total Cases vs Population
-- Shows percentage of population got Covid

SELECT Location, date, total_cases, population,(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidMDeaths$
--WHERE Location like '%states%'
ORDER BY 1,2

--  Showing Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
PercentPopulationInfected
FROM PortfolioProject..CovidMDeaths$
--WHERE Location like '%states%'
--GROUP BY location, population
GROUP BY location, population
ORDER BY 1,2

-- GROUP BY PercentPopulationInfected

SELECT continent, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
PercentPopulationInfected
FROM PortfolioProject..CovidMDeaths$
--WHERE Location like '%states%'
GROUP BY continent
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with the Highest Death Count Per Population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidMDeaths$
--WHERE Location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC



-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing Continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidMDeaths$
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
	(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidMDeaths$
--WHERE Location LIKE '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- All Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
	(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidMDeaths$
--WHERE Location LIKE '%states%'
WHERE continent is not null
ORDER BY 1,2




--   JOIN my data

SELECT *
FROM PortfolioProject..CovidMDeaths$  dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date


-- Showing Total Population vs Vaccinations
--Total amount of people in the world vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidMDeaths$  dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingpeopleVaccinated
--, (RollingPeopleVaccinated)
FROM PortfolioProject..CovidMDeaths$  dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingpeopleVaccinated
FROM PortfolioProject..CovidMDeaths$  dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE


WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingpeopleVaccinated
FROM PortfolioProject..CovidMDeaths$  dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingpeopleVaccinated
FROM PortfolioProject..CovidMDeaths$  dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingpeopleVaccinated
FROM PortfolioProject..CovidMDeaths$  dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


Select *
FROM PercentPopulationVaccinated

CREATE VIEW PercentPopulationInfected as
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
PercentPopulationInfected
FROM PortfolioProject..CovidMDeaths$
--WHERE Location like '%states%'
GROUP BY location, population
--ORDER BY 1,2

Select *
FROM PercentPopulationInfected
