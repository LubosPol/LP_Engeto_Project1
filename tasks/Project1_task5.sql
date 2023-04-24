/*
 * úkol 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
 * projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
 */

-- HDP versus platy
SELECT 
	tlpps.`year`,
	tlpps.industry_branch_name,
	tlpps.annual_percentage_change_in_wages,
	round(tlpps2.annual_percentage_change_in_GDP, 2) AS annual_percentage_change_in_GDP,
	round(tlpps2.annual_percentage_change_in_GDP - tlpps.annual_percentage_change_in_wages, 2) AS difference_in_percentage
FROM t_lubos_polak_project_sql_5_1 tlpps 
CROSS JOIN t_lubos_polak_project_sql_5_2 tlpps2 
	ON tlpps.`year` = tlpps2.`year` 
WHERE tlpps.`year` != 2006
ORDER BY industry_branch_name, `year` 
;

-- HDP versus platy v letech 2009 a 2010
SELECT 
	tlpps.`year`,
	tlpps.industry_branch_name,
	tlpps.annual_percentage_change_in_wages,
	round(tlpps2.annual_percentage_change_in_GDP, 2) AS annual_percentage_change_in_GDP,
	round(tlpps2.annual_percentage_change_in_GDP - tlpps.annual_percentage_change_in_wages, 2) AS difference_in_percentage
FROM t_lubos_polak_project_sql_5_1 tlpps 
CROSS JOIN t_lubos_polak_project_sql_5_2 tlpps2 
	ON tlpps.`year` = tlpps2.`year` 
WHERE tlpps.`year` != 2006 AND tlpps.`year` IN (2009, 2010) 
ORDER BY industry_branch_name, `year` 
;

-- HDP versus platy v letech 2012, 2013 a 2014
SELECT 
	tlpps.`year`,
	tlpps.industry_branch_name,
	tlpps.annual_percentage_change_in_wages,
	round(tlpps2.annual_percentage_change_in_GDP, 2) AS annual_percentage_change_in_GDP,
	round(tlpps2.annual_percentage_change_in_GDP - tlpps.annual_percentage_change_in_wages, 2) AS difference_in_percentage
FROM t_lubos_polak_project_sql_5_1 tlpps 
CROSS JOIN t_lubos_polak_project_sql_5_2 tlpps2 
	ON tlpps.`year` = tlpps2.`year` 
WHERE tlpps.`year` != 2006 AND tlpps.`year` IN (2012, 2013, 2014) 
ORDER BY industry_branch_name, `year` 
;


-- HDP versus ceny (spotřební koš)
SELECT 
	tlpps.`year`,
	tlpps.annual_percentage_change_in_prices,
	round(tlpps2.annual_percentage_change_in_GDP, 2) AS annual_percentage_change_in_GDP,
	round(tlpps2.annual_percentage_change_in_GDP - tlpps.annual_percentage_change_in_prices, 2) AS difference_in_percentage
FROM t_lubos_polak_project_sql_5_1 tlpps 
CROSS JOIN t_lubos_polak_project_sql_5_2 tlpps2 
	ON tlpps.`year` = tlpps2.`year` 
WHERE tlpps.`year` != 2006
GROUP BY annual_percentage_change_in_prices 
ORDER BY `year` 
;
