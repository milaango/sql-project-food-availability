

CREATE TABLE IF NOT EXISTS t_Milan_Angelis_project_SQL_primary_final AS (
SELECT *
FROM (
	(
	SELECT 
		date_part('year', cp.date_from ) AS "year",
		NULL AS quarter_of_year,
		cp.category_code::VARCHAR AS category_code,
		cpc."name" AS category_name,
		avg(cp.value) AS "value",
		'0' AS is_payroll,
		NULL::NUMERIC AS gdp
	FROM czechia_price cp
	JOIN czechia_price_category cpc
	ON cp.category_code = cpc.code
		WHERE cp.region_code IS NULL
	GROUP BY 
		date_part('year', cp.date_from), 
		cp.category_code,
		cpc."name"
	ORDER BY date_part('year', date_from)
	)
	UNION ALL
	(
	SELECT 
		cpay.payroll_year AS "year",
		cpay.payroll_quarter AS quarter_of_year,
		cpay.industry_branch_code AS category_code,
		cpib.name AS category_name,
		cpay.value AS value,
		'1' AS is_payroll,
		NULL::NUMERIC AS gdp
	FROM czechia_payroll cpay
	JOIN czechia_payroll_industry_branch cpib
	ON cpay.industry_branch_code = cpib.code
		WHERE cpay.value_type_code = '5958'
		AND cpay.calculation_code = '200'
	)
	UNION ALL
	(
	SELECT
		e."year" AS "year",
		NULL AS quarter_of_year,
		NULL AS category_code,
		NULL AS category_name,
		NULL AS value,
		'0' AS is_payroll,
		e.gdp::NUMERIC AS gdp
	FROM economies e
	WHERE country = 'Czech Republic'
		AND e.gdp IS NOT NULL
	)
)
ORDER BY is_payroll
);