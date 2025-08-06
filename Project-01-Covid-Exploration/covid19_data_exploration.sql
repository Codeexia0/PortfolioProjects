SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4



--DELETE FROM PortfolioProject.dbo.CovidDeaths
--WHERE [date] < '2020-01-28'
--   OR [date] > '2021-04-30';


--SELECT COUNT(continent)
--FROM CovidDeaths


--DELETE FROM PortfolioProject.dbo.CovidVaccinations
--WHERE [date] < '2020-01-28'
--   OR [date] > '2021-04-30';


--SELECT COUNT(continent)
--FROM CovidVaccinations



SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4



-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2




-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%state%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%state%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%state%'
GROUP BY location, population
ORDER BY 4 DESC



-- Showing the countries with Highest Death Count per Population
-- before using cast we would get weird numbers due to its datatype NVAR

SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC




-- Let's BREAK THINGS DOWNY BY CONTINENT
-- Showing The Continents With The Highest Death Per population


SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC -- IT IS NOT GOOD CUZ NORTH AMERICA ONLY USA COUNTED NOT CANADA


SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent IS NULL
GROUP BY Location
ORDER BY 2 DESC



-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100  AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100  AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2



-- Looking at the Total Population vs Vaccinations

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --instead of cast(.... AS INT) we can use CONVERT(INT, ....)
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- We wanna see total people vaccinated based on the date using CTE

WITH CTE_PopVac (Continent, Location, Date, Population,New_Vacciantions, RollingPeopleVaccinated)
AS
(
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location
 , dea.date) AS RollingPeopleVaccinated --instead of cast(.... AS INT) we can use CONVERT(INT, ....)
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND dea.location = 'Azerbaijan'
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS TotalPeopleVaccinatedPercentage
FROM CTE_PopVac



-- Temp Table


DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated --instead of cast(.... AS INT) we can use CONVERT(INT, ....)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS TotalPeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated



-- Create View to store date for later visualizations

-- 📘 VIEW: A view is a virtual table based on a SQL query.
-- It does not store data itself but shows results of a SELECT statement.
-- Useful for simplifying complex queries or restricting data access.

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated --instead of cast(.... AS INT) we can use CONVERT(INT, ....)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
