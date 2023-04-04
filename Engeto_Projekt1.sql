/*
 * úkol 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
 */

-- pomocný kód pro kontrolu:
SELECT * 
FROM czechia_payroll cp 
WHERE payroll_year = 2000
	AND value_type_code = 5958 
	AND industry_branch_code = 'A' 
	AND calculation_code = 100
;


SELECT 
	payroll_year,
	industry_branch_code,
	avg(value) AS average_wage
FROM czechia_payroll cp 
WHERE industry_branch_code IS NOT NULL
	AND value_type_code = 5958 
	AND calculation_code = 100
GROUP BY 
	payroll_year,
	industry_branch_code
ORDER BY 
	industry_branch_code, 
	payroll_year
;

