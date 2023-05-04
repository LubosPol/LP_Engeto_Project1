/*
 * 		VYTVOŘENÍ TABULKY MEZD A CEN POTRAVIN PRO ČR
 */ 

-- tvorba pomocné tabulky pro zjištění průměrných platů v jednotlivých letech

CREATE OR REPLACE TABLE t_lubos_polak_project_sql_wages AS
	SELECT
		cp.payroll_year AS 'year',
		cp.industry_branch_code,
		cpib.name AS 'industry_branch_name',
		avg(cp.value) AS 'average_wage'
	FROM czechia_payroll cp 
	JOIN czechia_payroll_industry_branch cpib 
		ON cp.industry_branch_code = cpib.code 
	WHERE industry_branch_code IS NOT NULL
		AND value_type_code = 5958 
		AND calculation_code = 100
	GROUP BY 
		payroll_year,
		industry_branch_code
;

-- tvorba pomocné tabulky, kde sloučím průměrné ceny jednotlivých výrobků do průměrů za jednotlivé roky

CREATE OR REPLACE TABLE t_lubos_polak_project_sql_prices AS
	SELECT
		avg(value) AS 'product_price',
		category_code,
		year(date_from) AS 'year'
	FROM czechia_price AS cp
	WHERE cp.region_code IS NULL
	GROUP BY 
		category_code, 
		year(date_from)
;

-- tvorba finální tabulky:

CREATE OR REPLACE TABLE t_lubos_polak_project_sql_primary_final AS
	SELECT
		tlpw.*,
		cpc.name AS 'product_name',
		cpc.price_value,
		cpc.price_unit,
		tlpp.product_price,
		e.GDP
	FROM t_lubos_polak_project_sql_prices AS tlpp
	JOIN t_lubos_polak_project_sql_wages AS tlpw
	     ON tlpw.`year` = tlpp.`year`
	JOIN czechia_price_category cpc
	     ON tlpp.category_code = cpc.code
	JOIN economies e 
		ON e.`year` = tlpp.`year`  AND 
		e.country LIKE 'Czech Republic'
;

SELECT *
FROM t_lubos_polak_project_sql_primary_final tlppspf ;



/*
 * 		VYTVOŘENÍ TABULKY PRO DALŠÍ EVROPSKÉ STÁTY
 */

CREATE OR REPLACE TABLE t_lubos_polak_project_sql_secondary_final AS
	SELECT 
		e.country,
		e.`year`,
		e.GDP,
		e.gini,
		e.population 
	FROM economies e
	LEFT JOIN countries c 
		ON e.country = c.country 
	WHERE gini IS NOT NULL AND 
		c.continent LIKE 'Europe'
	ORDER BY e.country, e.`year`
;

SELECT *
FROM t_lubos_polak_project_sql_secondary_final tlppssf ;
