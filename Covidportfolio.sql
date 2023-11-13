
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths,  
(CONVERT(decimal, total_deaths) / NULLIF(CONVERT(decimal, total_cases), 0)) * 100 AS Deathpercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


-- Looking at total cases vs population
-- Shows what percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)* 100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%spain%'
order by 1,2

-- Lookin at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%spain%'
Group by location, population
order by PercentPopulationInfected desc

-- Showing the countries with highest deth count per population 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%spain%'
Where continent is not null
Group by location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT




-- Showing the continents with the highest death count per population


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%spain%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS


Select date, SUM(new_cases) as Newcases, SUM(cast(new_deaths as int)) as NewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null and
new_deaths >0 and new_cases >0
Group by date
order by 1,2

--Total Global

Select SUM(new_cases) as Newcases, SUM(cast(new_deaths as int)) as NewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null and
new_deaths >0 and new_cases >0
--Group by date
order by 1,2


-- Total population VS Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT (FLOAT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is null or dea.continent <> ''
order by 2, 3


-- CTE

With PopvsVac (Continent, Location, date, population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT (FLOAT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is null or dea.continent <> ''
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations nvarchar(255), 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT (FLOAT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is null or dea.continent <> ''
--order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT (FLOAT, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is null or dea.continent <> ''
--order by 2, 3

Select *
From PercentPopulationVaccinated

jjjj