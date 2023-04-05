-- pomocný kód pro moji kontrolu:
SELECT * 
FROM czechia_payroll cp 
WHERE payroll_year = 2000
	AND value_type_code = 5958 
	AND industry_branch_code = 'A' 
	AND calculation_code = 100
;

-- tvorba pomocné tabulky pro zjištění průměrných cen v jednotlivých letech

CREATE TABLE IF NOT EXISTS t_Lubos_Polak_project_SQL_wages (
	id int,
	year int,
	industry_branch_code char(1),
	industry_branch_name varchar(128),
	average_wage int
);


INSERT INTO t_lubos_polak_project_sql_wages (
SELECT
	cp.id,
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
);

-- tvorba pomocné tabulky, kde sloučím průměrné ceny jednotlivých výrobků do průměrů za jednotlivé roky

CREATE TABLE IF NOT EXISTS t_Lubos_Polak_project_SQL_prices (
	product_price float,
	category_code int,
	year int
);

INSERT INTO t_lubos_polak_project_sql_prices (
SELECT
	value AS 'product_price',
	category_code,
	year(date_from)
FROM czechia_price AS cp
WHERE cp.region_code IS NULL
GROUP BY 
	category_code, 
	year(date_from)
);

-- tvorba finální tabulky:

CREATE TABLE IF NOT EXISTS t_Lubos_Polak_project_SQL_primary_final (
	id int,
	year int,
	industry_branch_code char(1),
	industry_branch_name varchar(128),
	average_wage int,
	product_name varchar(64),
	price_value float,
	price_unit varchar (4),
	product_price float,	
	GDP bigint
);

INSERT INTO t_lubos_polak_project_sql_primary_final (
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
);

SELECT *
FROM t_lubos_polak_project_sql_primary_final tlppspf ;

-- nakonec vymažu pomocné tabulky:
DROP TABLE t_lubos_polak_project_sql_prices;
DROP TABLE t_lubos_polak_project_sql_wages;



/*
 * úkol 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
 */



/*
 * úkol 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd??
 */



/*
 * úkol 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 */



/*
 * úkol 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
 */



/*
 * úkol 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
 * projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
 */



