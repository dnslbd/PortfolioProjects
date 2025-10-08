--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4;

--selection of data for further work

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--total cases VS total deaths in Ukraine

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Ukraine'
ORDER BY 1,2;

--top 5 days with the highest mortality rate in Ukraine

SELECT TOP 5
 location,
 date,
 total_cases,
 total_deaths,
 (CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Ukraine'
ORDER BY DeathPercentage DESC;

--countries with highest infection rate compared to population

SELECT location,
       population,
       MAX(total_cases) AS HighestInfectionCount, 
       MAX((total_deaths/total_cases)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--continents with highest death count per population

SELECT 
    continent,
    SUM(CAST(total_deaths AS FLOAT)) AS total_deaths,
    SUM(CAST(population AS FLOAT)) AS total_population,
    SUM(CAST(total_deaths AS FLOAT)) / SUM(CAST(population AS FLOAT)) AS deaths_per_capita
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY deaths_per_capita DESC;

--total population vs vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(INT, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,
  d.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v 
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

--use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(INT, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,
  d.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v 
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--temporary table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(INT, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,
  d.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v 
    ON d.location = v.location
    AND d.date = v.date
--WHERE d.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(INT, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,
  d.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v 
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3

SELECT  *
FROM PercentPopulationVaccinated




