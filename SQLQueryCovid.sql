select *
from coviddeath
where continent is not null
order by location, date;

--select *
--from covidvaccination
--order by location, date;

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..coviddeath
where continent is not null
order by 1,2


-- loking at total cases vs total death
-- shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from PortfolioProject..coviddeath
where location like 'ukr%'
order by 1,2


--loking at total cases vs population

select location, date, population, total_cases, (total_cases/population)*100 as infectedPopulationPercentage
from PortfolioProject..coviddeath
where location like 'ukr%'
order by 1,2


--loking at countries with Highest infection rate compared to Pooulation

select location, population, max(total_cases) as highestInfectedCount, max((total_deaths/population))*100 as maxInfectedPopulationPercentage
from PortfolioProject..coviddeath
--where location like 'ukr%'
where continent is not null
group by location, population
order by 4 desc


--showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as maxTotalDeathsCount 
from PortfolioProject..coviddeath
--where location like 'ukr%'
where continent is not null
group by location
order by 2 desc


--let's break things down by continent
--showing the continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as maxTotalDeathsCount 
from PortfolioProject..coviddeath
--where location like 'ukr%'
where continent is not null
group by continent
order by 2 desc


--GLOBAL numbers

select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/sum(new_cases) as deathPercentage
from PortfolioProject..coviddeath
--where location like 'ukr%'
where continent is not null
group by date
order by 1


-- all over

select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/sum(new_cases) as deathPercentage
from PortfolioProject..coviddeath
--where location like 'ukr%'
where continent is not null
--group by date
--order by 1


--loking at total population  vs vaccination


select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(convert(int, v.new_vaccinations)) OVER (partition by d.location order by d.date) as cumulativeTotalVaccinated
	--In this example, the OVER clause does not include PARTITION BY. 
	--This means that the function will be applied to all rows returned by the query. 
	--The ORDER BY clause specified in the OVER clause determines the logical order to which the AVG function is applied.
	--search: Producing a moving average and cumulative total
--(cumulativeTotalVaccinated/population)*100 u can chose CTE or TEMP
from PortfolioProject..coviddeath as d
JOIN PortfolioProject..covidvaccination as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by d.location, d.date;


--USE CTE
--(cumulativeTotalVaccinated/population)*100

-- column of CTE must be = select.column
-- if not = ,then eror

WITH PvsV (continent, location, date, population, new_vaccinations, cumulativeTotalVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(convert(float, v.new_vaccinations)) OVER (partition by d.location order by d.date) as cumulativeTotalVaccinated
from PortfolioProject..coviddeath as d
JOIN PortfolioProject..covidvaccination as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by d.location, d.date;
)
select *, (cumulativeTotalVaccinated/population)*100 as vaccinatedPopulationPercentage
from PvsV


--USE TEMP TABLE
--(cumulativeTotalVaccinated/population)*100

drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255) not null,
location nvarchar(255) not null,
date nvarchar(255) not null,
population float null,
new_vaccinations nvarchar(255) null,
cumulativeTotalVaccinated numeric
)

INSERT INTO #percentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(convert(float, v.new_vaccinations)) OVER (partition by d.location order by d.date) as cumulativeTotalVaccinated
from PortfolioProject..coviddeath as d
JOIN PortfolioProject..covidvaccination as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by d.location, d.date;

select *, (cumulativeTotalVaccinated/population)*100 as vaccinatedPopulationPercentage
from #percentPopulationVaccinated
--Сообщение 8115, уровень 16, состояние 2, строка 140
--Ошибка арифметического переполнения при преобразовании expression к типу данных int.
--Выполнение данной инструкции было прервано.
--Внимание! Значение NULL исключено в агрегатных или других операциях SET.
	--//rebuild tempTable datatype
	--//change int on float in SUM
	--//execute
	--//do the same thing on CTE modul


--CREATIN VIEW TO STORE DATA FOR LATER VISUALIZATIONS

create view vaccinatedPopulationPercentage as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(convert(float, v.new_vaccinations)) OVER (partition by d.location order by d.date) as cumulativeTotalVaccinated
from PortfolioProject..coviddeath as d
JOIN PortfolioProject..covidvaccination as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by d.location, d.date;

select *
from vaccinatedPopulationPercentage

