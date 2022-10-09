select * from CovidDeaths
WHERE Continent IS NOT NULL
order by 3,4

--select * from CovidVaccinations
--order by 3,4

SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
FROM PortfolioProject..CovidDeaths
Order By 1,2

-- Total cases Vs Total Deaths
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%STATES%'
Order By 1,2

-- LOOKING AT TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT Location, Date, Population, Total_Cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%STATES%'
Order By 1,2
 

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT Location, Population, MAX(Total_Cases) AS HighestInfectionCount, max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%INDIA%'
GROUP BY Location, Population
Order By PercentPopulationInfected Desc

-- SHOW THE COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION


SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%INDIA%'
WHERE Continent IS NOT NULL
GROUP BY Location
Order By TotalDeathCount Desc

-- BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%INDIA%'
WHERE Continent IS NOT NULL
GROUP BY Continent
Order By TotalDeathCount Desc

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%INDIA%'
WHERE Continent IS NULL
GROUP BY Location
Order By TotalDeathCount Desc

-- SHOWING THE CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%INDIA%'
WHERE Continent IS NOT NULL
GROUP BY Continent
Order By TotalDeathCount Desc

-- GLOBAL NUMBERS

SELECT Date, SUM(New_Cases) AS TotalCases, SUM(CAST(New_Deaths AS INT)) AS TotalDeaths, SUM(CAST(New_Deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%STATES%'
WHERE CONTINENT IS NOT NULL
GROUP BY Date 
Order By 1,2

SELECT  SUM(New_Cases) AS TotalCases, SUM(CAST(New_Deaths AS INT)) AS TotalDeaths, SUM(CAST(New_Deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%STATES%'
WHERE CONTINENT IS NOT NULL 
Order By 1,2


-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations 
--SUM(CAST(CV.New_Vaccinations AS INT)) OVER (Partition By CD.Location)
,SUM(CONVERT(INT, CV.New_Vaccinations)) OVER (Partition By CD.Location ORDER BY CD.Location, CD.Date) AS RollingPeopleVaccinated

FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
AND CD.Continent ='Africa'
ORDER BY 2,3

--- CTE

WITH PopVsVac( Continent, Location, Date, Population,NewVaccination, RollingPeopleVaccinated)
AS
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations 
--SUM(CAST(CV.New_Vaccinations AS INT)) OVER (Partition By CD.Location)
,SUM(CONVERT(INT, CV.New_Vaccinations)) OVER (Partition By CD.Location ORDER BY CD.Location, CD.Date) AS RollingPeopleVaccinated

FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
AND CD.Continent ='Africa'
-- ORDER BY 2,3
)
--SELECT * FROM PopVsVac

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations 
--SUM(CAST(CV.New_Vaccinations AS INT)) OVER (Partition By CD.Location)
,SUM(CONVERT(INT, CV.New_Vaccinations)) OVER (Partition By CD.Location ORDER BY CD.Location, CD.Date) AS RollingPeopleVaccinated

FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
AND CD.Continent ='Africa'
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- CREATE A VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS 
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations 
--SUM(CAST(CV.New_Vaccinations AS INT)) OVER (Partition By CD.Location)
,SUM(CONVERT(INT, CV.New_Vaccinations)) OVER (Partition By CD.Location ORDER BY CD.Location, CD.Date) AS RollingPeopleVaccinated

FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
AND CD.Continent ='Africa'

SELECT * FROM PercentPopulationVaccinated
