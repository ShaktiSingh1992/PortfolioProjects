
SELECT * FROM COVIDDEATHS WHERE continent IS NOT NULL 
SELECT location, date, total_cases, new_cases, total_deaths, population FROM COVIDDEATHS
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--'DEATHPERCENTAGE' SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DEATHPERCENTAGE FROM COVIDDEATHS
WHERE location LIKE '%AUSTRALIA%'
ORDER BY 1,2

--LOOKING AT THE TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS COVIDERCENTAGE FROM COVIDDEATHS
WHERE location LIKE '%AUSTRALIA%'
ORDER BY 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
max((total_cases/population)*100) AS PercentInfected
FROM COVIDDEATHS
--WHERE location LIKE '%AUSTRALIA%'
GROUP BY location, population
ORDER BY PercentInfected DESC

--SHOWING COUNTIRES WITH HIGHEST DEATH COUNT 

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDealthCount
FROM COVIDDEATHS
--WHERE location LIKE '%AUSTRALIA%'
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDealthCount DESC

--LETS BREAK THINGS DOWN BY CONTINENT 

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDealthCount
FROM COVIDDEATHS
--WHERE location LIKE '%AUSTRALIA%'
WHERE continent IS not NULL 
GROUP BY continent
ORDER BY TotalDealthCount DESC

--SHOWING CONTINETS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDealthCount
FROM COVIDDEATHS
--WHERE location LIKE '%AUSTRALIA%'
WHERE continent IS not NULL 
GROUP BY continent
ORDER BY TotalDealthCount DESC

--GLOBAL NUMBERS (date wise)

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(NEW_DEATHS AS INT)) AS TotalDeaths, 
(SUM(CAST(NEW_DEATHS AS INT))/SUM(new_cases))*100 AS DeathPercentage
 --total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM COVIDDEATHS
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBERS (in total)

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(NEW_DEATHS AS INT)) AS TotalDeaths, 
(SUM(CAST(NEW_DEATHS AS INT))/SUM(new_cases))*100 AS DeathPercentage
 --total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM COVIDDEATHS
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.Location ORDER BY DEA.Location, DEA.Date) AS RollingPeopleVaccinated

FROM COVIDDEATHS AS DEA
JOIN COVIDVACCINATION AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
where DEA.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
WITH POPVSVAC (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.Location ORDER BY DEA.Location, DEA.Date) AS RollingPeopleVaccinated

FROM COVIDDEATHS AS DEA
JOIN COVIDVACCINATION AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
where DEA.continent IS NOT NULL
--ORDER BY 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 from POPVSVAC

-------TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.Location ORDER BY DEA.Location, DEA.Date) AS RollingPeopleVaccinated

FROM COVIDDEATHS AS DEA
JOIN COVIDVACCINATION AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
where DEA.continent IS NOT NULL
--ORDER BY 2,3

select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated

---CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION 

CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.Location ORDER BY DEA.Location, DEA.Date) AS RollingPeopleVaccinated

FROM COVIDDEATHS AS DEA
JOIN COVIDVACCINATION AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
where DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated