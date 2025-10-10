-- Úkol 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší meziroční percentuální
-- nárůst)?

-- Výpočet meziročního růstu pro všechny kategorie potravin a za všechny sledované roky:

CREATE OR REPLACE VIEW v_milan_angelis_project_sql_food_percent_growth AS (
	WITH filtered_food AS (
		SELECT 
			tp."year",
			tp."category_name" AS category_name,
			tp.value AS price_current_year,
			LAG(tp.value) OVER (
				PARTITION BY tp."category_name"
				ORDER BY tp."year"
			) AS price_previous_year
		FROM t_Milan_Angelis_project_SQL_primary_final tp
		WHERE tp.is_payroll = '0'
			AND tp.gdp IS NULL
		ORDER BY 
			tp."category_name",
			tp."year"
	)
	SELECT
		ff."year",
		ff.category_name,
		(((ff.price_current_year::NUMERIC / ff.price_previous_year::NUMERIC) * 100) 
		- 100) AS percent_price_growth
FROM filtered_food ff
);

SELECT * FROM v_milan_angelis_project_sql_food_percent_growth;

-- Kategorie potraviny, která má nejnižší průměrný procentuální růst za sledované období:

SELECT
	category_name,
	ROUND(AVG(percent_price_growth), 2) AS avg_percent_growth
FROM v_milan_angelis_project_sql_food_percent_growth
GROUP BY category_name
ORDER BY AVG(percent_price_growth)
LIMIT 1;

-- Kategorie potraviny, která má nejnižší medián procentuálního růstu za sledované období:

SELECT
	category_name,
	ROUND(
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY percent_price_growth)::NUMERIC, 2
	) AS median_percent_growth
FROM v_milan_angelis_project_sql_food_percent_growth
GROUP BY category_name
ORDER BY PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY percent_price_growth)
LIMIT 1;