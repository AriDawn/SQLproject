-- Australia Death Percentage

SELECT Location, Date, Total_cases, Total_deaths, ROUND((total_deaths/total_cases)*100,2) As death_percentage
From PortfolioProject_Covid..CovidDeath
WHERE Location Like 'Australia' AND total_cases IS NOT NULL


-- Australia total cases vs population

SELECT Location, Date, Total_cases, Population, ROUND((total_cases/Population)*100,2) As PercentPopulationInfected
From PortfolioProject_Covid..CovidDeath
WHERE Location Like 'Australia' AND total_cases IS NOT NULL

--Looking at countries with highest infection rate
--We need to set continent to NOT NUll because that will accurately shows location as countries. 

SELECT Location, Population, MAX(Total_cases) AS MaxCases, MAX(ROUND((total_cases/Population)*100,2)) As PercentPopulationInfected
From PortfolioProject_Covid..CovidDeath
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Looking at countries with highest death count

SELECT Location, MAX(cast(Total_deaths as int)) AS TotalDeaths
From PortfolioProject_Covid..CovidDeath
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeaths DESC

--Looking at continent with highest death count
--When continent is NULL the location data will include continent, income status and World

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeaths
From PortfolioProject_Covid..CovidDeath
WHERE continent IS NULL
AND Location Not in ('World','International','European Union')
AND Location NOT LIKE '%income'
GROUP BY location
ORDER BY TotalDeaths DESC


--Global numbers
	--Global cases per day and death percentage
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as Total_deaths
, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject_Covid..CovidDeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY DeathPercentage DESC

	--Total Global cases and death percentage
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as Total_deaths
, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject_Covid..CovidDeath
WHERE continent IS NOT NULL

--Double checking if the data above is correct
--Select total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) As death_percentage
--FROM PortfolioProject_Covid..CovidDeath
--WHERE Location = 'World'
--ORDER BY Total_cases Desc
--The data is extremely close so I decided to keep it. It make sense because adding all countries we will get global data.

--Total population vs Vaccinations

SELECT dea.Location, dea.Date, Population, new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) AS People_vaccinated
FROM PortfolioProject_Covid..CovidDeath Dea
JOIN PortfolioProject_Covid.. CovidVaccination Vac
	ON Vac.location = dea.location AND Vac.date = Dea.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2


-- USE CTE To Find vaccination percentage

WITH PopvsVac (Location, Date, Population, new_vaccinations, total_vaccination)
as
(
SELECT dea.Location, dea.Date, Population, new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) AS People_vaccinated
FROM PortfolioProject_Covid..CovidDeath Dea
JOIN PortfolioProject_Covid.. CovidVaccination Vac
	ON Vac.location = dea.location AND Vac.date = Dea.date
WHERE dea.continent IS NOT NULL
)
SELECT location, MAX((total_vaccination/Population)*100) AS vaccination_percent
FROM PopvsVac
WHERE Population IS NOT NULL
GROUP BY location


--USE Temp Table

DROP Table if exists #TotalVaccination
Create Table #TotalVaccination
(
Location nvarchar(255), 
Date datetime,
Population numeric,
New_vaccinations numeric,
People_vaccinated numeric
)

INSERT INTO #TotalVaccination
SELECT dea.Location, dea.Date, Population, new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) AS People_vaccinated
FROM PortfolioProject_Covid..CovidDeath Dea
JOIN PortfolioProject_Covid.. CovidVaccination Vac
	ON Vac.location = dea.location AND Vac.date = Dea.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2

SELECT location, MAX((People_vaccinated/Population)*100) AS vaccination_percent
FROM #TotalVaccination
WHERE Population IS NOT NULL
GROUP BY location


--CREATE VIEW for Visualization with Tableau

Create View GlobalDeath as
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as Total_deaths
, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject_Covid..CovidDeath
WHERE continent IS NOT NULL

Create View ContinentDeath as
SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeaths
From PortfolioProject_Covid..CovidDeath
WHERE continent IS NULL
AND Location Not in ('World','International','European Union')
AND Location NOT LIKE '%income'
GROUP BY location

Create View CountriesInfected As
SELECT Location, Population, MAX(Total_cases) AS MaxCases, MAX(ROUND((total_cases/Population)*100,2)) As PercentPopulationInfected
From PortfolioProject_Covid..CovidDeath
WHERE continent IS NOT NULL
GROUP BY Location, Population

DROP VIEW if exists DateCountriesInfected
Create View DateCountriesInfected AS
SELECT Location, date, Population, MAX(Total_cases) AS MaxCases, MAX(ROUND((total_cases/Population)*100,2)) As PercentPopulationInfected
From PortfolioProject_Covid..CovidDeath
WHERE continent IS NOT NULL
GROUP BY Location, Population, date


SELECT *
FROM GlobalDeath

SELECT *
FROM ContinentDeath

SELECT *
FROM CountriesInfected

SELECT *
FROM DateCountriesInfected