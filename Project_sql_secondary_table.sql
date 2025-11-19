

CREATE TABLE IF NOT EXISTS t_Milan_Angelis_project_sql_secondary_final AS (
	SELECT DISTINCT 
		country,
		"year",
		gdp,
		gini,
		population
	FROM economies e
	WHERE country IN (
		SELECT DISTINCT c.country
		FROM countries c
		WHERE continent = 'Europe'
	)
	AND "year" >= 1990
	ORDER BY
		country,
		"year"
);

SELECT *
FROM t_Milan_Angelis_project_sql_secondary_final;
