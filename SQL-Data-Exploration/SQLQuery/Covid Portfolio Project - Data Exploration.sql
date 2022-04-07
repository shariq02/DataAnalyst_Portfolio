/*

Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

/* 

Table used: Covid_Death

*/

SELECT location, date, total_cases, new_cases, total_deaths, population
From PortFolioProject..Covid_Death
Where continent is not null
Order By 1,2;

--Total Cases Vs Total Death
--Likelihood of dying in Germany
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortFolioProject..Covid_Death
Where location = 'Germany'
Order By 1,2;

-- Total Cases Vs Population
-- Shows the percentage of population infected by covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasesPercentage
From PortFolioProject..Covid_Death
Where location = 'Germany'
Order By 1,2

--Countries with Highest Infection Rate compared with Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationInfectedPercentage
From PortFolioProject..Covid_Death
Group By location, population
Order By PopulationInfectedPercentage desc

--Countries with Highest Death Rate compared with Population
SELECT location, population, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population))*100 AS DeathPercentage
From PortFolioProject..Covid_Death
Group By location, population
Order By DeathPercentage desc

--Countries with Highest Death Count
SELECT location, MAX(cast(total_deaths AS int)) AS DeathCount
From PortFolioProject..Covid_Death
Where continent is not null
Group By location
Order By DeathCount desc

--Countries with Highest Cases
SELECT location, MAX(cast(total_cases AS int)) AS CasesCount
From PortFolioProject..Covid_Death
Where continent is not null
Group By location
Order By CasesCount desc

--Continent with Highest Death Count
SELECT location, MAX(cast(total_deaths AS int)) AS DeathCount
From PortFolioProject..Covid_Death
Where continent is null
Group By location
Order By DeathCount desc

--Continent with Highest Cases
SELECT location, MAX(cast(total_cases AS int)) AS CasesCount
From PortFolioProject..Covid_Death
Where continent is null
Group By location
Order By CasesCount desc

--Global Number
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortFolioProject..Covid_Death
Where continent is not null
Group By date
Order By 1,2

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortFolioProject..Covid_Death
Where continent is not null
Order By 1,2

/* 

Table used: Covid_Vaccination

*/

Select * From PortFolioProject..covidVaccination

--Total Population Vs Total Vaccination
Select covd.continent, covd.location, covd.date, covd.population, vacc.new_vaccinations
From PortFolioProject..Covid_Death covd
Join PortFolioProject..covidVaccination vacc
On covd.location = vacc.location
and covd.date = vacc.date
Where covd.continent is not null
Order By 2,3

Select covd.continent, covd.location, covd.date, covd.population, vacc.new_vaccinations,
	SUM(CONVERT(float, vacc.new_vaccinations)) OVER (Partition by covd.location Order By covd.location, covd.date)
	as RollingPeopleVaccination
From PortFolioProject..Covid_Death covd
Join PortFolioProject..covidVaccination vacc
On covd.location = vacc.location
and covd.date = vacc.date
Where covd.continent is not null
Order By 2,3


--Using CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccination)
as
(
Select covd.continent, covd.location, covd.date, covd.population, vacc.new_vaccinations,
	SUM(CONVERT(float, vacc.new_vaccinations)) OVER (Partition by covd.location Order By covd.location, covd.date)
	as RollingPeopleVaccination
From PortFolioProject..Covid_Death covd
Join PortFolioProject..covidVaccination vacc
On covd.location = vacc.location
and covd.date = vacc.date
Where covd.continent is not null
)
Select *, (RollingPeopleVaccination/population)*100 as VaccinationPercentage
From PopVsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime, 
	population numeric, 
	new_vaccinations numeric, 
	RollingPeopleVaccination numeric
)
Insert into #PercentPopulationVaccinated
Select covd.continent, covd.location, covd.date, covd.population, vacc.new_vaccinations,
	SUM(CONVERT(float, vacc.new_vaccinations)) OVER (Partition by covd.location Order By covd.location, covd.date)
	as RollingPeopleVaccination
From PortFolioProject..Covid_Death covd
Join PortFolioProject..covidVaccination vacc
On covd.location = vacc.location
and covd.date = vacc.date
Where covd.continent is not null

Select *, (RollingPeopleVaccination/population)*100 as VaccinationPercentage
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select covd.continent, covd.location, covd.date, covd.population, vacc.new_vaccinations,
	SUM(CONVERT(float, vacc.new_vaccinations)) OVER (Partition by covd.location Order By covd.location, covd.date)
	as RollingPeopleVaccination
From PortFolioProject..Covid_Death covd
Join PortFolioProject..covidVaccination vacc
On covd.location = vacc.location
and covd.date = vacc.date
Where covd.continent is not null

Select *
From PercentPopulationVaccinated
Order By 2,3