SELECT *
FROM CovidDeaths
ORDER BY 1,2

SELECT *
FROM CovidVaccinations
ORDER BY 1,2

--let's select data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Now let's look at total_cases vs total deaths 
--( We want to show or present the likelihood of dying if you contract covid in a country)


UPDATE CovidDeaths
SET  total_deaths = NULL
WHERE total_deaths = 0

UPDATE CovidDeaths
SET  total_cases = NULL
WHERE total_cases = 0

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentageCase 
FROM CovidDeaths
WHERE location LIKE '%ance%' 
ORDER BY 5 DESC

--Now let's look at total_cases vs population 
--( We want to show or present the likelihood of contracting Covid a country)

SELECT location, date, total_cases, total_deaths, population, (total_deaths/population)*100 AS PercentagePeopleInfected 
FROM CovidDeaths
WHERE location LIKE '%ance%' 
ORDER BY 5,6 DESC


--Perfect, now let's look at countries with highest infection rates comparated to population

SELECT location, population, MAX(total_cases) HighestInfectionCount,
	MAX((total_cases/population))*100 AS PercentagePeopleInfected 
FROM CovidDeaths
Group by location, population
ORDER BY 4 DESC

--Let's show countries with highest death count per population
--(i should clean my data before work on in , that's the consequence: update)
UPDATE CovidDeaths
SET  continent = NULL
WHERE continent = ' '

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
Group by location
ORDER BY 2 DESC

-- What if we break the same things down by continent

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount 
FROM CovidDeaths
WHERE continent IS NULL
Group by location
ORDER BY 2 DESC
-- data are not very accurate so, this method seems to be the best one to use here.

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
Group by continent
ORDER BY 2 DESC
--i didn't have to cast because it is already a float, its just for learning 

--showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
Group by continent
ORDER BY 2 DESC

--Global Numbers

--(i should clean my data before work on in , that's the consequence: update)
UPDATE CovidDeaths
SET  new_deaths = NULL
WHERE new_deaths = ' '

UPDATE CovidDeaths
SET  new_cases = NULL
WHERE new_cases = ' '

SELECT  date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
round((sum(new_deaths)/sum(new_cases))*100, 2) AS DeathPercentageCase 
FROM CovidDeaths
--WHERE location LIKE '%ance%' 
WHERE continent IS NOT NULL
Group by date
ORDER BY 1

-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations,  
	sum(cast(vac.new_vaccinations as float)) over (partition by dea.location ORDER BY dea.date, dea.location)
	AS EvolutionPeopleVaccinated
from CovidDeaths dea, CovidVaccinations vac
Where dea.date = vac.date And dea.location = vac.location And dea.continent IS NOT NULL
order by 2,3 
-- That works perfectly, every day that we have new vaccinations, this number is added to the previous EvolutionPeopleVaccinated in order to give us the update EvolutionPeopleVaccinated : fantastic!

--And finally Let's comparate this evolution to population by using a CTE

With PopvsVac (continent, location, date, population, new_vaccinations, EvolutionPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations,  
	sum(cast(vac.new_vaccinations as float)) over (partition by dea.location ORDER BY dea.date, dea.location)
	AS EvolutionPeopleVaccinated
from CovidDeaths dea, CovidVaccinations vac
Where dea.date = vac.date And dea.location = vac.location And dea.continent IS NOT NULL
--order by 2,3 
)

Select * , (EvolutionPeopleVaccinated/population)*100 AS UpdatePercentPeopleVaccinated
From PopvsVac

--That's work, fantastic !!! Let's have fun with his pair : temp table 
--I'm going to create a temp table to do the same task that i did in the previous query, the name that i choose is not really expressive but i did had some error so manage to figure out, now, it works perfectly
-- In order not to have too many error in the future, I should use in the top: DROP TABLE IF EXIST #PercentPeopleVaccinated 	
CREATE TABLE #PercentPeopleVacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations nvarchar(255),
EvolutionPeopleVaccinated numeric
)

insert into #PercentPeopleVacc
SELECT dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations,  
	sum(cast(vac.new_vaccinations as float)) over (partition by dea.location ORDER BY dea.date, dea.location)
	AS EvolutionPeopleVaccinated
from CovidDeaths dea, CovidVaccinations vac
Where dea.date = vac.date And dea.location = vac.location And dea.continent IS NOT NULL

Select * , (EvolutionPeopleVaccinated/population)*100 AS UpPercentPeoVac
From #PercentPeopleVacc


-- Create view for later visualisations

CREATE VIEW PeopleVaccinated AS
SELECT dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations,  
	sum(cast(vac.new_vaccinations as float)) over (partition by dea.location ORDER BY dea.date, dea.location)
	AS EvolutionPeopleVaccinated
from CovidDeaths dea, CovidVaccinations vac
Where dea.date = vac.date And dea.location = vac.location And dea.continent IS NOT NULL
--order by 2,3 
-- Geogeous, Awesome

Select * 
From PeopleVaccinated