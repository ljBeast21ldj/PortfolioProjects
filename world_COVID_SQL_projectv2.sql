 -- inspecting imported data

Select *
From [Portfolio Projects].dbo.CovidDeaths
Order by 3,4

Select *
From [Portfolio Projects].dbo.CovidVaccinations
Order by 3,4 

-- First I'm going to choose the data I'm going to use

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Projects].dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Observing the Total cases vs. Total Deaths (How many people who died actually had Covid-19
-- This shows the chances of a person dying if they contract COVID-19 depending on their country

Select location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as death_percentage
From [Portfolio Projects].dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Creating a view for visualization
USE [Portfolio Projects]
 GO
 
 CREATE VIEW dbo.cases_vs_deaths_world
 as
 Select location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as death_percentage
From [Portfolio Projects].dbo.CovidDeaths
Where continent is not null
--Order by 1,2
 GO

 Select *
 From cases_vs_deaths_world

 -- Observing the US cases vs deaths

Select location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as death_percentage
From [Portfolio Projects].dbo.CovidDeaths
Where location like '%states%'
Order by 1,2

-- Creating a View
USE [Portfolio Projects]
 GO
 
 CREATE VIEW dbo.cases_vs_deaths_us
 as
 Select location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as death_percentage
From [Portfolio Projects].dbo.CovidDeaths
Where location like '%states%'
--Order by 1,2
 GO

 Select *
 From cases_vs_deaths_us

-- Observing the total cases compared to the country's population
-- This shows what percentage of the population has contracted COVID

Select location, date, total_cases, Population,(total_cases/population) * 100 as covid_percentage
From [Portfolio Projects].dbo.CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2

-- Looking at Countries with the Highest COVID infection rate compared to it's population

Select location, Population, MAX(total_cases) as HighestInfectCount, MAX((total_cases/population)) * 100 as infection_percentage
From [Portfolio Projects].dbo.CovidDeaths
Where continent is not null
Group by location, population
Order by infection_percentage DESC

-- Creating a view for visualization
USE [Portfolio Projects]
 GO
 
 CREATE VIEW dbo.highest_infection_rate_countries
as
Select location, Population, MAX(total_cases) as HighestInfectCount, MAX((total_cases/population)) * 100 as infection_percentage
From [Portfolio Projects].dbo.CovidDeaths
Where continent is not null
Group by location, population
--Order by infection_percentage DESC
GO

Select *
From highest_infection_rate_countries
-- Observing Countries with the Highest Death toll per their population
-- Casting the total deaths so that it's read as an integer

Select location,Max(cast(Total_deaths as int)) as totalDeathToll
From [Portfolio Projects].dbo.CovidDeaths
Where continent is not null
Group by location
Order by totalDeathToll DESC

-- Creating a view to use for Tableau
USE [Portfolio Projects]
 GO

CREATE VIEW dbo.highest_countries_deaths 
as
Select location,Max(cast(Total_deaths as int)) as totalDeathToll
From [Portfolio Projects].dbo.CovidDeaths
Where continent is not null
Group by location
--Order by totalDeathToll DESC
GO

Select *
From highest_countries_deaths

-- Observing Continents with the highest death toll per their population
-- including the cast of total deaths so it reads as an integer instead varchar

Select location,Max(cast(Total_deaths as int)) as totalDeathToll
From [Portfolio Projects].dbo.CovidDeaths
Where continent is null
Group by location
Order by totalDeathToll DESC

-- Creating a view to use for Tableau

USE [Portfolio Projects]
 GO

 CREATE VIEW dbo.highest_continent_deaths
 AS
Select location,Max(cast(Total_deaths as int)) as totalDeathToll
From [Portfolio Projects].dbo.CovidDeaths
Where continent is null
Group by location
--Order by totalDeathToll DESC
GO

Select *
From highest_continent_deaths


-- Now it's time to observe the numbers globally
/* According to this by 2021 COVID had 150 million cases globally, 
claimed 3 million lives world-wide, and created a global death percentage of 2%
making COVID-19 one of the most deadliest viruses of all time.
*/

Select date, SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases) * 100 as deathPercentage
From [Portfolio Projects].dbo.CovidDeaths
Where continent is not null
Group by date
Order by 1,2


-- Now let's observe the vaccinations
/*
	Joining the tables CovidDeaths and CovidVaccinations in order to 
	see the percentage of the world population that got vaccinated
	vs. those who didn't.
*/
-- Looking at Total Population vs Vaccinations 
-- placing query in a CTE (Common Table Expression)
With PopvsVac (Continent, Location, Date, Population, new_vaccination, rolling_cnt_people_vacc) as
(
Select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vacc.new_vaccinations,
SUM(Cast(vacc.new_vaccinations as int)) 
OVER(PARTITION BY dea.location Order by dea.location, dea.date) as rolling_cnt_people_vacc
From [Portfolio Projects].dbo.CovidDeaths dea
Join [Portfolio Projects].dbo.CovidVaccinations vacc
	On dea.location = vacc.location
	and dea.date = vacc.date 
where dea.continent is not null
-- order by 2,3
 )
 Select *, (rolling_cnt_people_vacc/Population) * 100
 From PopvsVac

 
 
 -- Temp Table
 -- Once edited use: DROP Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 new_vaccinations numeric,
 rolling_cnt_people_vacc numeric
 )
Insert into #PercentPopulationVaccinated
Select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vacc.new_vaccinations,
SUM(Cast(vacc.new_vaccinations as int)) 
OVER(PARTITION BY dea.location Order by dea.location, dea.date) as rolling_cnt_people_vacc
From [Portfolio Projects].dbo.CovidDeaths dea
Join [Portfolio Projects].dbo.CovidVaccinations vacc
	On dea.location = vacc.location
	and dea.date = vacc.date 
where dea.continent is not null
-- order by 2,3
Select *, (rolling_cnt_people_vacc/Population) * 100
 From #PercentPopulationVaccinated


 -- Creating View to store data for visualizations later

 USE [Portfolio Projects]
 GO

 CREATE VIEW dbo.percent_population_vacc
 AS
 Select 
dea.continent, 
dea.location, 
dea.date,
dea.population, 
vacc.new_vaccinations,
SUM(Cast(vacc.new_vaccinations as int)) 
OVER(PARTITION BY dea.location Order by dea.location, dea.date) as rolling_cnt_people_vacc
From [Portfolio Projects].dbo.CovidDeaths dea
Join [Portfolio Projects].dbo.CovidVaccinations vacc
	On dea.location = vacc.location
	and dea.date = vacc.date 
where dea.continent is not null
GO
--order by 2,3

Select *
From percent_population_vacc

