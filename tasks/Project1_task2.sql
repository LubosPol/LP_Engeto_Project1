/*
 * úkol 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd??
 */

-- MLÉKO:
SELECT
	`year`,
	industry_branch_name,
	round (average_wage/product_price, 1) AS 'litres_of_milk_for_avg_wage'
FROM t_lubos_polak_project_sql_primary_final
WHERE (YEAR = (SELECT min(`year`) 
		FROM t_lubos_polak_project_sql_primary_final)
	OR
	YEAR = (SELECT max(`year`) 
		FROM t_lubos_polak_project_sql_primary_final)
		)
	AND product_name LIKE 'Mléko%'
ORDER BY industry_branch_name
;


-- CHLÉB:
SELECT
	`year`,
	industry_branch_name,
	round (average_wage/product_price, 1) AS 'kilograms_of_bread_for_avg_wage'
FROM t_lubos_polak_project_sql_primary_final
WHERE (
	YEAR = (SELECT min(`year`) 
		FROM t_lubos_polak_project_sql_primary_final)
	OR
	YEAR = (SELECT max(`year`) 
		FROM t_lubos_polak_project_sql_primary_final)
		)
	AND product_name LIKE 'Chléb%' 
ORDER BY industry_branch_name 
;