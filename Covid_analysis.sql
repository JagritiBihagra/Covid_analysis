select * from Covid_Project..CovidDeaths$ where continent is not null
select * from Covid_Project..CovidVaccinations$

select location,date, total_cases, new_cases, total_deaths, population 
from Covid_Project..CovidDeaths$ where continent is not null
order by 1 , 2

--Deaths vs cases
select location, date,  total_cases, total_deaths ,(total_deaths/total_cases)*100 as deathpercentage  
from Covid_Project..CovidDeaths$ where location like 'India'
order by 1,2

--Total cases vs population shows what %age of population got covid
select location, date,  population, total_cases,(total_cases/population)*100 as percentPopulationInfected  
from Covid_Project..CovidDeaths$ where location like 'India'
order by 1,2

-- countries with highest infection rate compared to Population 
select location,  population, max(total_cases) HighestInfectionCount ,max(total_cases/population)*100 as percentPopulationInfected  
from Covid_Project..CovidDeaths$ group by location, population
order by 4 desc


--Countries with the highest death count per poulation
select location, max(cast(total_deaths as int)) TotalDeathCount 
from Covid_Project..CovidDeaths$ where continent is not null
group by location
order by 2 desc

--lets break things down by contient (to get a cleaner data)
select location, max(cast(total_deaths as int)) TotalDeathCount 
from Covid_Project..CovidDeaths$  where continent is  null
group by location 
order by 2 desc
 
--Continent with highest death count
select continent, max(cast(total_deaths as int)) TotalDeathCount from Covid_Project..CovidDeaths$
where continent is not null
group by continent order by 2 desc

--Global numbers
select sum(new_cases) total_cases , sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))/ sum(new_cases)*100 as deathpercentage  
from Covid_Project..CovidDeaths$ where continent is not null
order by 1,2


select * from Covid_Project..CovidDeaths$ a join Covid_Project..CovidVaccinations$ b 
on a.date=b.date and a.location=b.location





--Total population vs vaccinations
select a.continent,a.location, a.date, a.population, b.new_vaccinations from Covid_Project..CovidDeaths$ a join Covid_Project..CovidVaccinations$ b 
on a.date=b.date and a.location=b.location 
where a.continent is not null
order by 1,2,3

select a.continent,a.location, a.date, a.population, b.new_vaccinations, sum(cast(b.new_vaccinations as int)) 
over(partition by a.location order by a.location , a.date) as RollingPeopleVaccinated
from Covid_Project..CovidDeaths$ a join Covid_Project..CovidVaccinations$ b 
on a.date=b.date and a.location=b.location 
where a.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CONVERT(int,b.new_vaccinations)) OVER (Partition by a.Location Order by a.location, a.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Project..CovidDeaths$ a join
Covid_Project..CovidVaccinations$ b 
	On a.location = b.location
	and a.date = b.date
where a.continent is not null 
--order by 2,3

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select a.continent, a.location,a.date, a.population, b.new_vaccinations
, SUM(CONVERT(int,b.new_vaccinations)) OVER (Partition by a.Location Order by a.location, a.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Project..CovidDeaths$ a join Covid_Project..CovidVaccinations$ b 
	On a.location =b.location
	and a.date = b.date
--where a.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CONVERT(int,b.new_vaccinations)) OVER (Partition by a.Location Order by a.location, a.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Project..CovidDeaths$ a join Covid_Project..CovidVaccinations$ b 
	On a.location = b.location
	and a.date =b.date
where a.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac