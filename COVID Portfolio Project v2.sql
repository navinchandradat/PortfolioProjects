/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


-- Select the data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you attract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Canada%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, Population, total_cases,  (total_cases/population) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Canada%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
Group by Location, Population
order by PercentPopulationInfected desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing Countries with the Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
Where continent is not null
Group by Location
order by TotalDeathCount desc



-- Above go back and change anything with a group by location to group by continent

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
Where continent is null
Group by location
order by TotalDeathCount desc



-- Showing the continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%Canada%'
where continent is not null
Group By date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%Canada%'
where continent is not null
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From PortfolioProject.. CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.. CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac





-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.. CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visulatizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.. CovidDeaths dea
Join PortfolioProject.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated



Create View TotalDeathCount as
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Canada%'
Where continent is null
Group by location


Select *
From TotalDeathCount
order by TotalDeathCount desc