select *
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4;

--select *
--FROM PortfolioProject..CovidDeaths
--order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

-- total_cases vs total_deaths 

select location, date, total_cases, total_deaths, 
(cast(total_deaths as float)/cast(total_cases as float))*100 as Deathpercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

-- total cases vs population 
select location,  date, population, total_cases,  
(cast(total_cases as float)/cast(population as float))*100 as CasesVsPop
FROM PortfolioProject..CovidDeaths 
where continent is not null
and location like '%india%'
order by 1,2;

select location, population, max(cast(total_cases as float)) as Highestinfectionscount,  
max((cast(total_cases as float)/cast(population as float))*100) as PercentpopulationInfected
FROM PortfolioProject..CovidDeaths
where continent is not null
--where location like '%india%'
group by location, population
order by PercentpopulationInfected desc;

-- Countries with highest death count per population 

select location, max(cast(total_deaths as int)) as Highestdeathcount
FROM PortfolioProject..CovidDeaths
where continent is not null
--and location like '%india%'
group by location
order by Highestdeathcount desc;


-- lets do things by continent

select continent, max(cast(total_deaths as int)) as Highestdeathcount
FROM PortfolioProject..CovidDeaths
where continent is not null
--and location like '%india%'
group by continent
order by Highestdeathcount desc;

-- data is bit messy so we try to run another query

select location, max(cast(total_deaths as int)) as Highestdeathcount
FROM PortfolioProject..CovidDeaths
where continent is  null
--and location like '%india%'
group by location
order by Highestdeathcount desc;

--Global numbers

select date, sum(new_cases) as total_New_cases, sum(new_deaths) as total_new_deaths
            ,(sum(new_deaths)/sum(new_cases))*100 as Newdeathpercentage
FROM PortfolioProject..CovidDeaths
where continent is  not null and new_cases <>0
group by date
order by 1,2;

select sum(new_cases) as total_New_cases, sum(new_deaths) as total_new_deaths
            ,(sum(new_deaths)/sum(new_cases))*100 as Newdeathpercentage
FROM PortfolioProject..CovidDeaths
where continent is  not null and new_cases <>0
order by 1,2;

-- Vaccination table data

select *
FROM PortfolioProject..Covidvaccination;

-- Joining the two tables for better comparison


Select * 
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date

-- looking at total population vs vaccinations done 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE 

With popvsvac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as 
( 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/population)*100
from popvsvac;


-- Creating a temporary table 

DROP TABLE  #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations NVARCHAR(255),
RollingPeopleVaccinated numeric, 
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	Sum(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated;


-- Creating Views 

Create view PercentPopulationVaccinatedview as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * 
from PercentPopulationVaccinatedview;