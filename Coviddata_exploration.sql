select * from coviddeaths;
select * from covidvaccination;
select * from coviddeaths order by 3, 4;
select * from covidvaccination order by 3, 4;
-- select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths order by 1,2;

-- Looking at Total Cases Vs Total Deaths
-- Percentage of Deaths in different locations
select location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 as percentage_deaths
from coviddeaths 
order by 1,2 desc;

-- shows what percentage of population got covid

select location, date, total_cases, population , (total_cases/population)*100 as infection_rate
from coviddeaths 
order by 1,2 desc;

-- Looking at countries with higest infection rate compared to population

select  location, population, MAX(total_cases) as highestinfectionrate, MAX((total_cases/population)*100) as percentagepopulationinfected
from coviddeaths 
group by location, population
order by percentagepopulationinfected;

-- Looking at countries with highest Death count per population

SELECT location, MAX(CAST(total_deaths AS unsigned)) AS totalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totalDeathCount;

-- Gobal Numbers
SELECT -- date, 
SUM(new_cases), SUM(new_deaths), SUM(new_deaths) * 100 / SUM(new_cases) AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL;
-- GROUP BY date
-- ORDER BY date, SUM(new_cases)
-- LIMIT 0, 1000;

-- Joining two tables CovidDeaths and CovidVaccination
select * from coviddeaths d 
left join covidvaccination v on
d.location=v.location and d.date=v.date;

-- looking at total population vs vaccination

select d.continent, d.location, d.date , d.population, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location, d.date order by d.location, d.date)
from coviddeaths d 
left join covidvaccination v on
d.location=v.location and d.date=v.date
where d.continent is not null
order by 2,3;


-- use CTE

 with popvsvac ( continent, location, date , population, new_vaccinations, rollingsum)
 as
 (
select d.continent, d.location, d.date , d.population, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location, d.date order by d.location, d.date) as rollingsum
from coviddeaths d 
left join covidvaccination v on
d.location=v.location and d.date=v.date
where d.continent is not null
-- order by 2,3;
)
select *, (rollingsum/population)*100
from popvsvac;

-- Temp Table
drop table if exists #percpopvac
Create table #percpopvac
(
continent varchar(225),
location varchar(255),
date datetime,
population numeric,
new_vacinations numeric,
rollingsum numeric
)
insert into #percpopvac
select d.continent, d.location, d.date , d.population, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location, d.date order by d.location, d.date) as rollingsum
from coviddeaths d 
left join covidvaccination v on
d.location=v.location and d.date=v.date
-- where d.continent is not null
-- order by 2,3;

select *, (rollingsum/population)*100
from #percpopvac

DROP TABLE IF EXISTS percpopvac;
CREATE TEMPORARY TABLE percpopvac (
  continent VARCHAR(225),
  location VARCHAR(255),
  date DATETIME,
  population NUMERIC,
  new_vacinations NUMERIC,
  rollingsum NUMERIC
);

INSERT INTO percpopvac
SELECT d.continent, d.location, STR_TO_DATE(d.date, '%d/%m/%Y'), d.population, v.new_vaccinations,
       SUM(v.new_vaccinations) OVER (PARTITION BY d.location, d.date ORDER BY d.location, d.date) AS rollingsum
FROM coviddeaths d 
LEFT JOIN covidvaccination v ON d.location = v.location AND d.date = v.date;

SELECT *, (rollingsum / population) * 100
FROM percpopvac;
