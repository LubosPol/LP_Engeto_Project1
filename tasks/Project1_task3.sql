/*
 * úkol 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 */

-- Pomocný dotaz ke zjištění, jestli jsou záznamy pro každou kategorii potravin přes celé období:

SELECT 
	product_name, 
	COUNT(`year`) AS 'count of records'
FROM t_lubos_polak_project_sql_primary_final
GROUP BY product_name  
;


-- Pomocný pohled pro vyčíslení meziročních procentuálních změn jednotlivých kategorií potravin:

CREATE OR REPLACE VIEW v_Lubos_Polak_project_sql_price_annual_changes AS 
SELECT 
	DISTINCT(tpf.product_name),
	tpf.`year`,
	tpf.product_price,
	tpf1.product_price AS 'product_price_in_previous_year',
	round(((tpf.product_price / tpf1.product_price) * 100)-100, 1) AS 'annual_percentual_change'
FROM t_lubos_polak_project_sql_primary_final tpf 
JOIN t_lubos_polak_project_sql_primary_final tpf1 ON tpf.`year` = tpf1.`year` + 1
WHERE tpf.product_name = tpf1.product_name
HAVING tpf.product_name NOT LIKE 'Jakostní víno bílé'
ORDER BY  tpf.`year`
;

-- Dotaz k zobrazení průměrné procentuální změny jednotlivých kategorií potravin přes celé sledované období:

SELECT 
	product_name,
	max(annual_percentual_change) + abs(min(annual_percentual_change)) AS 'max_difference',
	round(avg (annual_percentual_change), 2) AS 'avg_annual_change'
FROM v_lubos_polak_project_sql_price_annual_changes
GROUP BY product_name 
ORDER BY avg(annual_percentual_change)
;



-- Dotaz ke zjištění cen vybraných kategorií potravin:
SELECT 
	`year`, 
	product_name, 
	product_price 
FROM t_lubos_polak_project_sql_primary_final
WHERE product_name LIKE 'Cukr krystalový' OR product_name LIKE 'Přírodní minerální voda uhličitá'
GROUP BY product_name, `year`;