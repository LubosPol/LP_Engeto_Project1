-- pomocný kód pro moji kontrolu:
SELECT * 
FROM czechia_payroll cp 
WHERE payroll_year = 2000
	AND value_type_code = 5958 
	AND industry_branch_code = 'A' 
	AND calculation_code = 100
;

-- tvorba pomocné tabulky pro zjištění průměrných platů v jednotlivých letech

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

SELECT
	year,
	industry_branch_code,
	industry_branch_name,
	average_wage,
	average_wage - lag(average_wage)
		OVER (PARTITION BY `industry_branch_code` ORDER BY `year`) AS difference
FROM t_lubos_polak_project_sql_primary_final tlpf
GROUP BY YEAR, industry_branch_code 
ORDER BY industry_branch_code, year 
;


/*
 * úkol 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd??
 */

SELECT
	year,
	industry_branch_name,
	round (average_wage/product_price, 1) AS litres_of_milk_for_average_wage
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

SELECT
	year,
	industry_branch_name,
	round (average_wage/product_price, 1) AS kilograms_of_bread_for_average_wage
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
	round(avg(product_price), 2) AS average_price,
	round(max(product_price), 2) AS max_price,
	concat (round((100 - avg(product_price)/max(product_price)*100), 1), '%') AS average_growth
FROM t_lubos_polak_project_sql_primary_final tlpf
GROUP BY product_name
ORDER BY avg(product_price)/max(product_price) DESC
;

-- odpověď hledám na základě průměrné ceny produktu


/*
 * úkol 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
 */


SELECT * FROM t_lubos_polak_project_sql_primary_final tlpf

/*
 * úkol 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
 * projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
 */

