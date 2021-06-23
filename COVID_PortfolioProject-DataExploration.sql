/*
COVID19 Data Exploration

Skills Used: JOIN,CTE'S,TEMP TABLE, WINDOWS FUNCTIONS, AGGREGATE FUNCTIONS, CREATING VIEWS, CONVERTING DATA TYPE
*/

SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


-- Select Data that we are going to be starting with
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Total Cases vs Total Deaths

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where Location like '%INDIA%'
and continent is not null
order by 1,2

-- Affected Population vs Population

SELECT location,date,Population,total_cases,(total_cases/Population)*100 as AffectedPopulation
FROM PortfolioProject..CovidDeaths
Where Location like '%INDIA%'
and continent is not null
order by 1,2

SELECT location,date,Population,total_cases,(total_cases/Population)*100 as AffectedPopulation
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location,Population,max(total_cases) as HighestInfectionCount,Max((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by location,Population
order by PercentPopulationInfected desc

SELECT location,Population,max(total_cases) as HighestInfectionCount,Max((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by location,Population
order by HighestInfectionCount desc

-- Countries with Highest Death Count per Population

SELECT location,MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

------------------------------------------------------------------------------------------------------------------------------------------------------------
--Break by continent
-- Showing contintents with the highest death count per population

SELECT continent,MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases,SUM(CAST(NEW_DEATHS AS INT))AS Total_Deaths,SUM(CAST(NEW_DEATHS AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by DeathPercentage desc

--VACCINATION
SELECT *
FROM PortfolioProject..CovidVaccinations

-- Total Population vs Vaccinations
--Joining CovidDeaths & CovidVaccinations

SELECT *
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is not null

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
		SUM(CONVERT(INT,CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) as RollingPopulationVaccinated
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH POPvsVAC (continent,location,date,population,new_vaccinations,RollingPopulationVaccinated)
as
(
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
		SUM(CONVERT(INT,CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) as RollingPopulationVaccinated
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is not null
)
SELECT *,(RollingPopulationVaccinated/population)*100
FROM POPvsVAC

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar(255),
loaction nvarchar(255),
date nvarchar(255),
population numeric,
new_vaccinations numeric,
RollingPopulationVaccinated numeric
)
INSERT INTO #PercentagePopulationVaccinated
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
		SUM(CAST(CV.new_vaccinations as int)) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) as RollingPopulationVaccinated
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is not null
SELECT *,(RollingPopulationVaccinated/population)*100
FROM #PercentagePopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentagePopulationVaccinated AS 
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
		SUM(CAST(CV.new_vaccinations as int)) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) as RollingPopulationVaccinated
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is not null