-- Úkol 1: Rosotu v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

CREATE OR REPLACE VIEW v_Milan_Angelis_Project_sql_average_payroll AS (
	SELECT
		tp.category_code,
		tp.category_name,
		tp."year",
		avg(tp.value) AS average_payroll
	FROM t_Milan_Angelis_Project_sql_primary_final tp
	WHERE is_payroll = '1'
	GROUP BY 
		tp.category_code,
		tp.category_name,
		tp."year"
	ORDER BY 
		tp.category_code, 
		tp.category_name,
		tp."year"
);

SELECT *
FROM v_Milan_Angelis_Project_sql_average_payroll;
