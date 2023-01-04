SELECT *
FROM Portfolio_SQL_Projects..covid_deaths
-- Location column also contains continents and income groups
WHERE continent IS NOT NULL
ORDER BY 2


-- Total cases vs total deaths in Australia
-- The likelihood of death if you contract Covid in Australia
SELECT location, date, total_cases_per_million, total_deaths_per_million,
		ROUND((total_deaths_per_million / total_cases_per_million),2) AS death_ratio
FROM Portfolio_SQL_Projects..covid_deaths
WHERE location = 'Australia' AND continent IS NOT NULL
ORDER BY 1, 2


-- Total cases vs population in Australia
-- The percentage of population got Covid
SELECT location, date, total_cases_per_million, population,
		ROUND(((total_cases_per_million * 1000)/population),2) AS cases_per_pop
FROM Portfolio_SQL_Projects..covid_deaths
WHERE location = 'Australia' AND continent IS NOT NULL
ORDER BY 1, 2


-- Country with the highest infection rate per population
SELECT location, population,
		SUM(new_cases) AS infection_count,
		ROUND((SUM(new_cases) / population) * 100, 2) AS infection_rate
FROM Portfolio_SQL_Projects..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC


-- Which countries have the highest death count since Covid happened
-- Total Death count for each country (People who actually died from Covid)
SELECT location, population, MAX(total_deaths) as total_deaths_count
FROM Portfolio_SQL_Projects..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_deaths_count DESC

-- Total death count by continent
SELECT continent, SUM(new_deaths) as total_deaths_count
FROM Portfolio_SQL_Projects..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths_count DESC


-- Which continent has the highest death rate
SELECT continent, MAX(total_deaths) as total_deaths_count
FROM Portfolio_SQL_Projects..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths_count DESC


-- Which continent has the highest death rate
-- ***Location is a better column to keep, just need to filter out the rows that is NULL in continent column
SELECT location, MAX(total_deaths) as total_deaths_count
FROM Portfolio_SQL_Projects..covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_deaths_count DESC



-- Total cases and deaths globally
SELECT SUM(new_cases) AS total_cases_global, 
		SUM(new_deaths) AS total_deaths_global,
		(SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage_global
FROM Portfolio_SQL_Projects..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2



-- Global figures day by day since covid happened
SELECT date, 
		SUM(new_cases) AS total_cases_global, 
		SUM(new_deaths) AS total_deaths_global,
		(SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage_global
FROM Portfolio_SQL_Projects..covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


-- Joining 2 tables
-- Looking at the rolling vaccinated percentage compared to population, using CTE
WITH vax_per_pop (continent, location, date, population, new_vaccinations, rolling_vaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinated
FROM Portfolio_SQL_Projects..covid_deaths d
JOIN Portfolio_SQL_Projects..covid_vaccinations v
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL
)

SELECT *, (rolling_vaccinated / population )*100 AS rolling_vaccinated_percentage
FROM vax_per_pop
ORDER BY 2,3


-- Create View to store data for later visualisation
CREATE VIEW vaccinated_pop_percentage AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinated
FROM Portfolio_SQL_Projects..covid_deaths d
JOIN Portfolio_SQL_Projects..covid_vaccinations v
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL
)

SELECT * FROM vaccinated_pop_percentage