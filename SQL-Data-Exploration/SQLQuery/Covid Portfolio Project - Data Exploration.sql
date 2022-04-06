/*

Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT location, date, total_cases, new_cases, total_deaths, population
From PortFolioProject..Covid_Death
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
Group By location
Order By DeathCount desc

--Countries with Highest Cases
SELECT location, MAX(cast(total_cases AS int)) AS CasesCount
From PortFolioProject..Covid_Death
Group By location
Order By CasesCount desc