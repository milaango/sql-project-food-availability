-- Úkol 4: Existuje rok, ve kterém byl meziroční růst cen potravin výrazně
-- vyšší než růst mezd (větší než 10 %)?


-- Poddotaz 1: srovnání průměrného meziročního růstu potravin (celkově) a meziročního procentuálního růstu mezd

CREATE OR REPLACE VIEW v_milan_angelis_project_sql_avg_growth_food_and_payroll_per_years AS (
	SELECT
		a."year",
		ROUND(
			((a.average_payroll::NUMERIC / 
			(LAG(a.average_payroll) OVER (ORDER BY a."year")))*100) - 100, 2
		) AS percent_payroll_growth,
		b.avg_percent_food_growth
	FROM (
		SELECT
			vpay."year",
			ROUND(AVG(vpay.average_payroll::NUMERIC), 2) AS average_payroll
		FROM v_Milan_Angelis_Project_sql_average_payroll vpay
		GROUP BY vpay."year"
		ORDER BY vpay."year"
	) a
	JOIN (
		SELECT
			vfg."year",
			ROUND(AVG(vfg.percent_price_growth::NUMERIC), 2) AS avg_percent_food_growth
		FROM v_milan_angelis_project_sql_food_percent_growth vfg
		GROUP BY vfg."year"
		ORDER BY vfg."year"
	) b
	ON a."year" = b."year"
);

SELECT
	"year",
	avg_percent_food_growth,
	percent_payroll_growth,
	avg_percent_food_growth::NUMERIC - percent_payroll_growth::NUMERIC AS percent_difference
FROM v_milan_angelis_project_sql_avg_growth_food_and_payroll_per_years
WHERE percent_payroll_growth::NUMERIC > 0
	AND avg_percent_food_growth::NUMERIC > 0;

-- poznámka: jelikož nás zajímají pouze roky, kdy mzdy i ceny potravin rostly, jsou odfiltrovány
-- roky, při nichž je jedna z proměnných menší nebo rovna 0


-- Poddotaz 2: Rozsáhlejší dotaz, pomocí něhož lze vyfiltrovat jednotlivé kategorie,
-- které vykázaly v některém z let výrazný růst oproti mzdám

WITH differences_growth AS (
	SELECT
		c."year",
		c.category_name,
		ROUND(c.percent_price_growth, 2) AS percent_price_growth,
		d.percent_payroll_growth,
		ROUND(percent_price_growth - d.percent_payroll_growth, 2) AS percent_difference,
		CASE 
			WHEN percent_price_growth - d.percent_payroll_growth > 10 THEN 1
			ELSE 0
		END AS is_difference_significant
	FROM v_milan_angelis_project_sql_food_percent_growth c
	CROSS JOIN
	(
		SELECT
			apay."year",
			ROUND(
				((apay.average_payroll::NUMERIC / 
				(LAG(apay.average_payroll) OVER (ORDER BY apay."year")))*100) - 100, 2
			) AS percent_payroll_growth
		FROM (
			SELECT
				vpay."year",
				ROUND(AVG(vpay.average_payroll::NUMERIC), 2) AS average_payroll
			FROM v_Milan_Angelis_Project_sql_average_payroll vpay
			GROUP BY vpay."year"
			ORDER BY vpay."year"
		) apay
	) d
	WHERE c."year" = d."year"
		AND (
		c.percent_price_growth::NUMERIC > 0
		AND d.percent_payroll_growth::NUMERIC > 0
		)
	ORDER BY c."year", c."category_name"
)
SELECT
	"year",
	percent_price_growth,
	percent_payroll_growth,
	percent_difference,
	category_name
FROM differences_growth
WHERE is_difference_significant = 1
ORDER BY "year";