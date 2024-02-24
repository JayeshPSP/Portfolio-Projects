
Select *
From PortfolioProject..['Covid Deaths']
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..['Covid Vaccinations']
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['Covid Deaths']
order by 1,2

-- Total Cases v/s Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)
From PortfolioProject..['Covid Deaths']
order by 1,2


SELECT Location, date, total_cases, total_deaths, 
    CASE 
        WHEN TRY_CONVERT(float, total_cases) = 0 THEN NULL 
        ELSE TRY_CONVERT(float, total_deaths) / TRY_CONVERT(float, total_cases) * 100 
    END AS Death_Percentage
FROM PortfolioProject..['Covid Deaths']
Where location like '%India'
ORDER BY 1, 2


-- Total Cases v/s Population

SELECT Location, date, total_cases, Population, 
    CASE 
        WHEN TRY_CONVERT(float, total_cases) = 0 THEN NULL 
        ELSE TRY_CONVERT(float, total_cases) / TRY_CONVERT(float, Population) * 100 
    END AS 'People with Covid'
FROM PortfolioProject..['Covid Deaths']
--Where location like '%India'
ORDER BY 1, 2


-- Looking at countries with Highest Infection Rate compared to Pupulation


SELECT 
    Location, 
    Population, 
    MAX(total_cases) AS HighestInfectioncount,
    MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM 
    PortfolioProject..['Covid Deaths']

GROUP BY 
    Location, Population
ORDER BY 
    PercentPopulationInfected DESC

-- Showing Countries with highest death count per population

SELECT 
    Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..['Covid Deaths']
Where continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Filtering these numbers continent wise



-- Showing continents with highest death count 

SELECT 
	Continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..['Covid Deaths']
Where continent is not null 
GROUP BY Continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT SUM(New_Cases) AS Total_New_Cases, SUM(CAST(New_Deaths AS INT)) AS Total_New_Deaths, 
    CASE 
        WHEN SUM(New_Cases) = 0 THEN NULL 
        ELSE (SUM(CAST(New_Deaths AS INT)) / SUM(New_Cases)) * 100 
    END AS DeathPercentage
FROM PortfolioProject..['Covid Deaths'] 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1

--Total Population v/s Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths'] dea
Join PortfolioProject..['Covid Vaccinations'] vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths'] dea
Join PortfolioProject..['Covid Vaccinations'] vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Tables

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccination numeric, RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths'] dea
Join PortfolioProject..['Covid Vaccinations'] vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths'] dea
Join PortfolioProject..['Covid Vaccinations'] vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated