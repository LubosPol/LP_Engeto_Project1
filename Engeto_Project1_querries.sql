
/*
 * úkol 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
 */

SELECT
	`year`,
	industry_branch_name,
	average_wage,
	average_wage - lag(average_wage)
		OVER (PARTITION BY industry_branch_code ORDER BY `year`) AS annual_change
FROM t_lubos_polak_project_sql_primary_final tlpf
GROUP BY `year`, industry_branch_code 
ORDER BY `year`, industry_branch_name 
;

SELECT
	industry_branch_name,
	average_wage,
	max(average_wage) - min(average_wage) AS max_difference_in_wages
FROM t_lubos_polak_project_sql_primary_final tlpf
GROUP BY industry_branch_code 
ORDER BY max(average_wage) - min(average_wage)
;

/*
 * úkol 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd??
 */

-- MLÉKO:
SELECT
	`year`,
	industry_branch_name,
	round (average_wage/product_price, 1) AS litres_of_milk_for_avg_wage
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
	round (average_wage/product_price, 1) AS kilograms_of_bread_for_avg_wage
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


/*
 * úkol 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 */

SELECT
	product_name,
	round(min(product_price),1) AS min_price,
	round(max(product_price), 1) AS max_price,
	concat (round((max(product_price)/min(product_price)*100)-100, 1), '%') AS growth
FROM t_lubos_polak_project_sql_primary_final tlpf
GROUP BY product_name
ORDER BY max(product_price)/min(product_price)
-- LIMIT 1
;

/*
 * úkol 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
 */


SELECT
	tlpf.`year`,
	tlpf.industry_branch_name,
	round((tlpf.average_wage - lag(tlpf.average_wage) OVER (PARTITION BY tlpf.industry_branch_code ORDER BY tlpf.`year`))
		/
		((lag(tlpf.average_wage) OVER (PARTITION BY tlpf.industry_branch_code ORDER BY tlpf.`year`))/100), 2) 
		AS annual_percentage_change_in_wages,
	t2.annual_percentage_change_in_prices,
	abs(round((tlpf.average_wage - lag(tlpf.average_wage) OVER (PARTITION BY tlpf.industry_branch_code ORDER BY tlpf.`year`))
		/
		((lag(tlpf.average_wage) OVER (PARTITION BY tlpf.industry_branch_code ORDER BY tlpf.`year`))/100), 2)  - t2.annual_percentage_change_in_prices)
			AS percentage_changes_difference
FROM t_lubos_polak_project_sql_primary_final tlpf
CROSS JOIN (
			SELECT
				`year`,
				round(avg (tlpp.product_price), 2) AS avg_basket_price,
				round((avg(tlpp.product_price) - lag(avg(tlpp.product_price)) OVER (PARTITION BY tlpp.category_code ORDER BY `year`))
				/
				((lag(avg(tlpp.product_price)) OVER (PARTITION BY tlpp.category_code ORDER BY `year`))/100), 2)
					AS annual_percentage_change_in_prices
			FROM t_lubos_polak_project_sql_prices tlpp
			GROUP BY `year` 
			) t2
WHERE tlpf.`year` = t2.`year`
GROUP BY tlpf.`year`, tlpf.industry_branch_code 
ORDER BY YEAR, percentage_changes_difference DESC  
;

-- vzal jsem řešení z úkolu 1, kde jsou vyjádřené rozdíly mezd v letech, dále jsem z dat cen vytvořil spotřebitelský koš (ceny všech produktů z jednoho roku), 
-- výběry jsem sloučil pomocí skalárního součinu


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
