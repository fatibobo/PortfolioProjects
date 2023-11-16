
-- I have here Covid data downloaded from https://ourworldindata.org/covid-deaths
-- I have saved the data into 2 separate files.
-- I am going to expore the data, check for different things (like Total Cases vs Total Deaths recorded in my home country Nigeria etc


Select *
From PortfolioProject..CovidDeaths
--Where continent is not null
order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Will select a few columns to work with
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null


-- Will check for Total Cases vs Total Deaths to see the likelihood of dying if you contract covid in Nigeria

Select location, date, total_cases,  total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Nigeria'


-- Will check what percentage of population got Covid

Select location, date, population, total_cases, (total_cases / population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'Nigeria'



-- Checking for Countries with Hightest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
group by location, population
order by PercentPopulationInfected desc



-- Checking for Countries with Highest Death Count per Population

Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
group by location, population
order by TotalDeathCount desc



-- Checking for Continent with the highest death count per population

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc



-- Global Numbers - Checking for total infection cases and deaths per day 

Select date, SUM(new_cases) as total_cases,  SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date 
order by 1,2


-- Checking for total cases vs death
Select SUM(new_cases) as total_cases,  SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



-- Looking at Total Population vs Vaccination USING CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated / population) *100 PercentPopVacinated
From PopvsVac
-- End to CTE



-- Looking at Total Population vs Vaccination Using TEMP TABLE

DROP Table if exists #PercentPopulationVaccination
Create Table #PercentPopulationVaccination
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated / population) *100 PercentPopVacinated
From #PercentPopulationVaccination
-- End of Temp table



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccination as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccination