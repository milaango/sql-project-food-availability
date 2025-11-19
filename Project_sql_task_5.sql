-- Úkol 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste
-- výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném
-- nebo následujícím roce výraznějším růstem?


SELECT
	a."year",
	ROUND((a.gdp::NUMERIC/(LAG(a.gdp) OVER (ORDER BY a."year")) * 100 - 100), 2) AS gdp_percent_growth,
	b.avg_percent_food_growth,
	d.percent_payroll_growth
FROM (
	SELECT DISTINCT 
		tp."year", 
		tp.gdp
	FROM t_milan_angelis_project_sql_primary_final tp
	WHERE tp.gdp IS NOT NULL
	ORDER BY tp."year"
) a
LEFT JOIN (
	SELECT
		vfg."year",
		ROUND(AVG(vfg.percent_price_growth::NUMERIC), 2) AS avg_percent_food_growth
	FROM v_milan_angelis_project_sql_food_percent_growth vfg
	GROUP BY vfg."year"
	ORDER BY vfg."year"
	) b
ON a."year" = b."year"
LEFT JOIN (
	SELECT
		c."year",
		ROUND(
		((c.average_payroll::NUMERIC / 
		(LAG(c.average_payroll) OVER (ORDER BY c."year")::NUMERIC))*100) - 100, 2
		) AS percent_payroll_growth
	FROM (
		SELECT
			vpay."year",
			ROUND(AVG(vpay.average_payroll::NUMERIC), 2) AS average_payroll
		FROM v_Milan_Angelis_Project_sql_average_payroll vpay
		GROUP BY vpay."year"
		ORDER BY vpay."year"
	) c) d
ON a."year" = d."year";