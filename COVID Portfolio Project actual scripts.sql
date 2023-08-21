Select * from CovidDeaths
where continent is not null
order by 3,4

--Select * from CovidVaccinations
--order by 3,4

--select the data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from CovidDeaths
where location like '%state%' and continent is not null
order by 1,2

--looking at total cases vs population
--shows what % of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths
where continent is not null
--where location like '%state%'
order by 1,2

--looking at countries with highest infection rate compare to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths
--where location like '%state%'
where continent is not null
group by location, population
order by PercentagePopulationInfected desc

--Showing countries with the highest death Count population
Select Location, MAX(Total_deaths) as TotalDeathCount
from CovidDeaths
--where location like '%state%'
where continent is not null
group by Location
order by TotalDeathCount desc

--let's break things down by continent

--showing the continent with the hihgest death count

Select continent, MAX(Total_deaths) as TotalDeathCount
from CovidDeaths
--where location like '%state%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers

Select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths) / SUM(new_cases) * 100 as DeathPercentage
from CovidDeaths
--where location like '%state%' and 
where continent is not null
group by date
order by 1,2

--looking at total Population vs Vacination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated / population) * 100
from PopvsVac

--TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated / population) * 100
from #PercentPopulationVaccinated


--Createing View to store data for later for visualization

create view PercentPopulationVaccinated
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated