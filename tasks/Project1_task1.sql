/*
 * úkol 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
 */

SELECT
	`year`,
	industry_branch_name,
	average_wage,
	average_wage - lag(average_wage)
		OVER (PARTITION BY industry_branch_code ORDER BY `year`) AS 'annual_change'
FROM t_lubos_polak_project_sql_primary_final tlpf
GROUP BY `year`, industry_branch_code 
ORDER BY `year`, industry_branch_name 
;

SELECT
	industry_branch_name,
	average_wage,
	max(average_wage) - min(average_wage) AS 'max_difference_in_wages'
FROM t_lubos_polak_project_sql_primary_final tlpf
GROUP BY industry_branch_code 
ORDER BY max(average_wage) - min(average_wage)
;