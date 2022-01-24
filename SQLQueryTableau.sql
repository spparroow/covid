
--Queries used for Tableau Project



-- 1. 

Select sum(new_cases) as totalCases,
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
--SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

select location, sum(cast(new_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
--Where location like '%states%'
where continent is null 
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc


-- 3.

select location, population, max(total_cases) as HighestInfectionCount,
	Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeath
--Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


-- 4.

select location, population, date, max(total_cases) as HighestInfectionCount,
	max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeath
--Where location like '%states%'
group by Location, Population, date
order by PercentPopulationInfected desc












-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out


-- 1.

Select d.continent, d.location, d.date, d.population,
	MAX(v.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath d
Join PortfolioProject..CovidVaccination v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
group by d.continent, d.location, d.date, d.population
order by 1,2,3




-- 2.
Select SUM(new_cases) as total_cases,
	SUM(cast(new_deaths as float)) as total_deaths,
	SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
--SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeath
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population,
	MAX(total_cases) as HighestInfectionCount,
	Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From PortfolioProject..CovidDeath
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by dea.Location Order by d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath d
Join PortfolioProject..CovidVaccination v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select Location, Population,date,
	MAX(total_cases) as HighestInfectionCount,
	Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc