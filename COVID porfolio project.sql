--select data that we are going to use
select location,date,total_cases,new_cases,total_deaths,population 
from PorfolioProject..coviddeaths$ 
where continent is not null
order by 3,4

-- looking at total cases vs total deaths
select location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PorfolioProject..coviddeaths$
where location like '%states%' 
order by 1,2

--looking at total cases vs population
select location, date, total_cases,population, (total_cases/population)*100 as PercentagePopulationInfected
from PorfolioProject..coviddeaths$
where location like '%states%'
order by 1,2

--find the highest infection rate country
select location, MAX(total_cases) as HighestInfectionCount,population, MAX((total_cases/population))*100 as PercentagePopulationInfected
from PorfolioProject..coviddeaths$
where continent is not null
group by location,population
order by PercentagePopulationInfected desc

--find countries with highest death count
select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PorfolioProject..coviddeaths$ 
--where continent is not null
group by location
order by HighestDeathCount desc

--find continents with highest death count
select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PorfolioProject..coviddeaths$ 
where continent is null
group by location
order by HighestDeathCount desc

select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PorfolioProject..coviddeaths$ 
where continent is null
group by location
order by HighestDeathCount desc

--Global numbers
select sum(new_cases) as 'new cases',sum(cast(new_deaths as int)) as 'new deaths', sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Total Death Percentage'
from PorfolioProject..coviddeaths$
where continent is not null
--group by date

select * 
from PorfolioProject..coviddeaths$ dea
join PorfolioProject..covidvaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date

--find the total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PorfolioProject..coviddeaths$ dea
join PorfolioProject..covidvaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PorfolioProject..coviddeaths$ dea
join PorfolioProject..covidvaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *
from PopvsVac


--TEMP table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PorfolioProject..coviddeaths$ dea
join PorfolioProject..covidvaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--create view to store data for visualisation
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PorfolioProject..coviddeaths$ dea
join PorfolioProject..covidvaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated