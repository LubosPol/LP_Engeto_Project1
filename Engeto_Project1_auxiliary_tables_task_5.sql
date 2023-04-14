
SELECT *
FROM t_lubos_polak_project_sql_primary_final tlppspf ;


/*
 * úkol 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
 * projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
 */

-- pomocné tabulky pro úkol 5:

CREATE TABLE IF NOT EXISTS t_Lubos_Polak_project_SQL_5_1 (
	year int,
	industry_branch_name varchar(128),
	annual_percentage_change_in_wages float,
	annual_percentage_change_in_prices float
);

INSERT INTO t_lubos_polak_project_sql_5_1 (
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
);


CREATE TABLE IF NOT EXISTS t_Lubos_Polak_project_SQL_5_2 (
	year int,
	annual_percentage_change_in_GDP float
);

INSERT INTO t_lubos_polak_project_sql_5_2 (
SELECT
	tlppspf.`year`,
	round(((tlppspf.GDP - lag(tlppspf.GDP) OVER ( ORDER BY `year`))/lag(tlppspf.GDP) OVER ( ORDER BY `year`))*100, 2)
		AS annual_percentage_change_in_GDP
FROM t_lubos_polak_project_sql_primary_final tlppspf 
GROUP BY `year` 
);

SELECT *
FROM t_lubos_polak_project_sql_5_1 ;

SELECT *
FROM t_lubos_polak_project_sql_5_2 ;
