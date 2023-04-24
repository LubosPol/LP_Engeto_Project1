
/*
 * úkol 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
 */

-- pomocné tabulky pro úkol 4:


CREATE OR REPLACE TABLE t_lubos_polak_project_sql_wages_annual_changes AS
SELECT
	`year`,
	industry_branch_name,
	average_wage,
	lag(average_wage)
		OVER (PARTITION BY industry_branch_code ORDER BY `year`) AS 'wage_in_previous_year',
	round((average_wage / lag(average_wage)
		OVER (PARTITION BY industry_branch_code ORDER BY `year`) * 100)-100, 1) AS 'annual_percentage_change_in_wages'
FROM t_lubos_polak_project_sql_primary_final tlpf
GROUP BY `year`, industry_branch_code 
ORDER BY `year`, industry_branch_name 
;

CREATE OR REPLACE TABLE t_lubos_polak_project_sql_prices_annual_changes AS
SELECT 
	DISTINCT(tpf.product_name),
	tpf.`year`,
	tpf.product_price,
	tpf1.product_price AS 'product_price_in_previous_year',
	round(((tpf.product_price / tpf1.product_price) * 100)-100, 1) AS 'annual_percent_change_in_prices'
FROM t_lubos_polak_project_sql_primary_final tpf 
JOIN t_lubos_polak_project_sql_primary_final tpf1 ON tpf.`year` = tpf1.`year` + 1
WHERE tpf.product_name = tpf1.product_name 
ORDER BY tpf.product_name,  tpf.`year`
;

CREATE OR REPLACE TABLE t_lubos_polak_project_sql_basket_prices_annual_changes AS
SELECT
	`year`,
	round(avg (tlpp.product_price), 2) AS 'avg_basket_price',
	round((avg(tlpp.product_price) - lag(avg(tlpp.product_price)) OVER (PARTITION BY tlpp.category_code ORDER BY `year`))
	/
	((lag(avg(tlpp.product_price)) OVER (PARTITION BY tlpp.category_code ORDER BY `year`))/100), 1)
		AS 'annual_percentage_change_in_basket_prices'
FROM t_lubos_polak_project_sql_prices tlpp
GROUP BY `year` 
;




/*
 * úkol 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
 * projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
 */

-- pomocné tabulky pro úkol 5:

CREATE OR REPLACE TABLE t_lubos_polak_project_sql_5_1 AS
	SELECT
		tlpf.`year`,
		tlpf.industry_branch_name,
		round((tlpf.average_wage - lag(tlpf.average_wage) OVER (PARTITION BY tlpf.industry_branch_code ORDER BY tlpf.`year`))
			/
			((lag(tlpf.average_wage) OVER (PARTITION BY tlpf.industry_branch_code ORDER BY tlpf.`year`))/100), 2) 
				AS annual_percentage_change_in_wages,
		t2.annual_percentage_change_in_prices
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
;


CREATE OR REPLACE TABLE t_lubos_polak_project_sql_5_2 AS
SELECT
	tlppspf.`year`,
	round(((tlppspf.GDP - lag(tlppspf.GDP) OVER ( ORDER BY `year`))/lag(tlppspf.GDP) OVER ( ORDER BY `year`))*100, 2)
		AS annual_percentage_change_in_GDP
FROM t_lubos_polak_project_sql_primary_final tlppspf 
GROUP BY `year` 
;

SELECT *
FROM t_lubos_polak_project_sql_5_1 ;

SELECT *
FROM t_lubos_polak_project_sql_5_2 ;
