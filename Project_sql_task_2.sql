-- Úkol 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné
-- období v dostupných datech cen a mezd?

WITH comparison_prices_payroll AS (
SELECT
	tp."year",
	tp.category_name AS commodity,
	ROUND(tp.value::NUMERIC, 2) AS commodity_price, 
	apay.average_payroll
FROM t_milan_angelis_project_sql_primary_final tp
LEFT JOIN (
	SELECT
		vpay."year",
		ROUND(AVG(vpay.average_payroll::NUMERIC), 2) AS average_payroll
	FROM v_Milan_Angelis_Project_sql_average_payroll vpay
	WHERE vpay."year" IN (2006, 2018)
	GROUP BY vpay."year"
) apay
ON 
	tp."year" = apay."year"
WHERE
	(
	tp.category_name ILIKE '%mléko%'
	OR 
	tp.category_name ILIKE '%chléb%'
	)
	AND 
	tp."year" IN (2006, 2018)
ORDER BY tp.category_name
)
SELECT
	"year",
	commodity,
	ROUND(average_payroll::NUMERIC/commodity_price::NUMERIC) AS accessible_amount_of_commodity
FROM comparison_prices_payroll
ORDER BY 
	commodity,
	"year";

