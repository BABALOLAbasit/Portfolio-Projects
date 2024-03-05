Select *
From PortfolioProject..CovidDeaths$
order by 3,4


--Select *
--From PortfolioProject..CovidVaccination$
--order by 3,4

 Select Location, date, total_cases, new_cases, total_deaths, population
 from PortfolioProject..CovidDeaths$
 order by 1,2 

 --Looking at Total_cases vs Total_deaths
  Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths$
 where location like '%africa%'
 order by 1,2 

 --Looking at the Total Cases vs Population
 --shows what percentage of population got covid
 Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
 from PortfolioProject..CovidDeaths$
 where location like '%africa%'
 order by 1,2 

 --Looking at countries with highest infection rate compared to population

  Select Location, Population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
 from PortfolioProject..CovidDeaths$
 --where location like '%africa%'
 Group by Location, Population
 order by PercentPopulationInfected desc

 --Showin country with Highest Death count per Population

  Select Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths$
 --where location like '%africa%'
 Group by Location
 order by TotalDeathCount desc 

 --LET'S BREAK THINGS DOWN BY CONTINENT



--showing the continents with highest DeathCount per population

    Select continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths$
 --where location like '%africa%'
 where continent is not null
 Group by continent
 order by TotalDeathCount desc

 --GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL 
        ELSE SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0) * 100 
    END AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths$
WHERE 
    continent IS NOT NULL
--GROUP BY date
ORDER BY  1,2;


--Covid Vaccination

--Looking at Total Population vs Vaccinations

--Use CTE

with PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as

(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
 

 --TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
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
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
 
select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

   
--Creating views to store data for later visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

Create View TotalDeathCount as
 Select Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths$
 --where location like '%africa%'
 Group by Location
--order by TotalDeathCount desc

Select *
From TotalDeathCount