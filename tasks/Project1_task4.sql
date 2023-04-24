/*
 * úkol 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
 */

-- Dotaz pro zobrazení počtu záznamů v tabulce platů, kde je rozdíl mezi mzdami dle odvětví a cenami dle produktů > 10%
SELECT
	twach.`year`,
	count(twach.industry_branch_name) AS 'count_of_records_where_gap>10'
FROM t_lubos_polak_project_sql_wages_annual_changes twach
JOIN t_lubos_polak_project_sql_prices_annual_changes tpach ON twach.`year` = tpach.`year` 
WHERE abs(twach.annual_percentage_change_in_wages - tpach.annual_percent_change_in_prices) > 10
GROUP BY twach.`year`
ORDER BY twach.`year`
;


-- Dotaz k zobrazení meziročních rozdílů mezi mzdami dle odvětví a cenami dle produktů > 10%:
SELECT
	twach.`year`,
	twach.industry_branch_name,
	twach.annual_percentage_change_in_wages,
	tpach.product_name,
	tpach.annual_percent_change_in_prices,
	twach.annual_percentage_change_in_wages - tpach.annual_percent_change_in_prices AS 'gap_between_wage_and_price'
FROM t_lubos_polak_project_sql_wages_annual_changes twach
JOIN t_lubos_polak_project_sql_prices_annual_changes tpach ON twach.`year` = tpach.`year` 
WHERE abs(twach.annual_percentage_change_in_wages - tpach.annual_percent_change_in_prices) > 10
ORDER BY gap_between_wage_and_price, industry_branch_name 
;

-- Následné dotazy pro rok 2012, počty výskytů, hodnoceno přes kombinace odvětví X cenová kategorie:
-- podmínka rozdílu přes 10%
SELECT
	twach.`year`,
	count(*) AS 'count_of_records_where > 10%'
FROM t_lubos_polak_project_sql_wages_annual_changes twach
JOIN t_lubos_polak_project_sql_prices_annual_changes tpach ON twach.`year` = tpach.`year` 
WHERE abs(twach.annual_percentage_change_in_wages - tpach.annual_percent_change_in_prices) > 10 AND twach.`year`= 2012
ORDER BY twach.annual_percentage_change_in_wages - tpach.annual_percent_change_in_prices, industry_branch_name 
;

-- podmínka rozdílu maximálně 10%
SELECT
	twach.`year`,
	count(*) AS 'count_of_records_where <= 10%'
FROM t_lubos_polak_project_sql_wages_annual_changes twach
JOIN t_lubos_polak_project_sql_prices_annual_changes tpach ON twach.`year` = tpach.`year` 
WHERE abs(twach.annual_percentage_change_in_wages - tpach.annual_percent_change_in_prices) <= 10 AND twach.`year`= 2012
ORDER BY twach.annual_percentage_change_in_wages - tpach.annual_percent_change_in_prices, industry_branch_name 
;


-- Dotaz pro zobrazení meziročních rozdílů mezi mzdami dle odvětví a cenou vyjádřenou spotřebitelským košem > 10%:
SELECT
	twach.`year`,
	twach.industry_branch_name,
	twach.annual_percentage_change_in_wages,
	tbach.annual_percentage_change_in_basket_prices,
	twach.annual_percentage_change_in_wages - tbach.annual_percentage_change_in_basket_prices AS 'gap_between_wage_and_basket_price'
FROM t_lubos_polak_project_sql_wages_annual_changes twach
JOIN t_lubos_polak_project_sql_basket_prices_annual_changes tbach ON tbach.`year` = twach.`year` 
WHERE abs(twach.annual_percentage_change_in_wages - tbach.annual_percentage_change_in_basket_prices) > 10
ORDER BY gap_between_wage_and_basket_price 
;