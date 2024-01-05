--DATA EXPLORATION IN SQL

SELECT *
FROM PortforlioProject..CovidDeaths
order by 3,4

--SELECT *
--FROM PortforlioProject..CovidVaccinations
--order by 3,4

--Selecting DATA that we are going to USE.

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortforlioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths.
--Likelihood of dying if one contracts Covid-19 in your country.

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortforlioProject..CovidDeaths
where location like '%kenya%'
order by 1,2


-- Looking at Total cases Vs Polulation.
-- Shows what percentage of the Population got covid-19

Select Location, date, total_cases, new_cases, population, (total_cases/population) * 100 as PercentagePopulationInfected
FROM PortforlioProject..CovidDeaths
--where location like '%kenya%'
order by 1,2


--Looking at infection rate,

Select Location, date, total_cases, new_cases, population, (new_cases/population) * 100 as RateOfInfection
FROM PortforlioProject..CovidDeaths
--where location like '%kenya%'
order by 1,2

--Looking at Countries with highest infection rate compared to Population.

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as HighestInfectionRate
FROM PortforlioProject..CovidDeaths
--where location like '%kenyan%'
group by location, population
order by HighestInfectionRate DESC

--Looking at Countries with highest death count per population.

Select location, Population, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortforlioProject..CovidDeaths
--where location like '%kenyan%'
where continent is not null
group by location, population
order by HighestDeathCount DESC

--LETS BREAK THINGS DOWN BY CONTINENT.
--Showing continents with the highest death counts.

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortforlioProject..CovidDeaths
--where location like '%kenyan%'
where continent is not null
group by continent
order by HighestDeathCount DESC

--GOLBAL NUMBERS

Select SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortforlioProject..CovidDeaths
where continent is not null
--where location like '%kenya%'
--group by date
order by 1,2


--Looking at total Population vs Vaccination.

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortforlioProject..CovidDeaths dea
Join PortforlioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
 where dea.continent is not null
 order by 2,3 


 --USING CTE

 With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortforlioProject..CovidDeaths dea
Join PortforlioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
 where dea.continent is not null
 --ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population) * 100 as PopulationVaccinationPercentage
FROM PopvsVac


--TEMP TABLES

CREATE TABLE #PercentageofPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentageofPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortforlioProject..CovidDeaths dea
Join PortforlioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 
 SELECT *, (RollingPeopleVaccinated/population) * 100 as PopulationVaccinationPercentage
FROM #PercentageofPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION.
 
Create view PercentageofPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortforlioProject..CovidDeaths dea
Join PortforlioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

