--MY PORTFOLIO PROJECT 1
--Covid 19 Data Exploration in SQL skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select *
From CovidDeath


-- Select Data that we are going to be starting with
Select Location, date,  new_cases, total_cases, new_deaths, total_deaths, population
From CovidDeath
order by location,date 


-- Total Cases, Total Deaths, DeathPercentage: Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPct
From CovidDeath
Where location like '%Azerbaijan%'
order by 1,2


-- Total Cases vs Population: Shows what percentage of population infected with Covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as InfectedPct
From CovidDeath
--where location like '%Azerbaijan%' 
order by 1,2


-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as MAX_InfectionCount,  Max((total_cases/population))*100 as MAX_InfectedPct
From CovidDeath
--Where location like '%Azerbaijan%'
Group by Location, Population
order by MAX_InfectedPct desc


-- Countries with Total Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeath
From CovidDeath
--Where location like '%Azerbaijan%' and 
Group by Location
order by TotalDeath desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeath
From CovidDeath
--Where location like '%Azerbaijan%'
Where continent is not null 
Group by continent
order by TotalDeath desc



-- GLOBAL NUMBERS
Select SUM(new_cases) Total_cases, SUM(cast(new_deaths as int)) Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Pct
From CovidDeath
--Where location like '%Azerbaijan%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations: Shows Percentage of Population that has recieved at least one Covid Vaccine
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(float,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) AS RollingPeopleVaccinated
From CovidDeath CD
Join CovidVaccination CV
	On CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(float,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) AS RollingPeopleVaccinated
From CovidDeath CD
Join CovidVaccination CV
	On CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null 
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
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(float,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath CD
Join CovidVaccination CV
	On CD.location = CV.location
	and CD.date = CV.date
--where CD.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(float,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath CD
Join CovidVaccination CV
	On CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null 
--order by 2,3


