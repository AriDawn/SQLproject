-- Australia Death Percentage

SELECT Location, Date, Total_cases, Total_deaths, ROUND((total_deaths/total_cases)*100,2) As death_percentage
From PortfolioProject_Covid..CovidDeath
WHERE Location Like 'Australia' AND total_cases IS NOT NULL


-- Australia total cases vs population

SELECT Location, Date, Total_cases, Population, ROUND((total_cases/Population)*100,2) As PercentPopulationInfected
From PortfolioProject_Covid..CovidDeath
WHERE Location Like 'Australia' AND total_cases IS NOT NULL

--Looking at countries with highest infection rate

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

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeaths
From PortfolioProject_Covid..CovidDeath
WHERE continent IS NULL
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
