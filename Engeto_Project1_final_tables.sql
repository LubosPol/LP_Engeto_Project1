/*
 * 		VYTVOŘENÍ TABULKY MEZD A CEN POTRAVIN PRO ČR
 */ 

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



/*
 * 		VYTVOŘENÍ TABULKY PRO DALŠÍ EVROPSKÉ STÁTY
 */

CREATE TABLE IF NOT EXISTS t_Lubos_Polak_project_SQL_secondary_final (
	country varchar(32),
	`year` int,
	GDP BIGINT,
	gini float,
	population int
);


INSERT INTO t_lubos_polak_project_sql_secondary_final (
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
);

SELECT *
FROM t_lubos_polak_project_sql_secondary_final tlppssf ;
