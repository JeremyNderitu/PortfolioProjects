SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER by 3,4


--SELECT data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%kingdom%'
and continent is not null
ORDER BY 1,2


--Looking at Total cases vs population
--Shows what Percentage of population got Covid

SELECT location, date, Population, total_cases, total_deaths,(total_cases/population)*100 AS percentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highestInfectionCount, MAX(total_cases/population)*100 AS percentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
GROUP BY Location, Population
ORDER BY percentPopulationInfected DESC

--showing Countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS totalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
WHERE continent is not null
GROUP BY Location
ORDER BY totalDeathCount DESC


-- LET's Break things down by continent

SELECT continent, MAX(cast(total_deaths as int)) AS totalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeathCount DESC


--showing the continents with highest death count

SELECT continent, MAX(cast(total_deaths as int)) AS totalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeathCount DESC



--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/sum(new_cases)*100 as death_percentage -- total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
  dea.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--use  CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
  dea.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (rollingPeopleVaccinated/population) * 100
FROM PopvsVac



--TEMP table

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
  dea.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (rollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
  dea.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated

DROP DATABASE day2_database2