/*
 * úkol 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 */

-- Dotaz k zobrazení procentuálních meziročních změn:
SELECT 
	DISTINCT(tpf.product_name),
	tpf.`year`,
	tpf.product_price,
	tpf1.product_price AS 'product_price_in_previous_year',
	concat(round(((tpf.product_price / tpf1.product_price) * 100)-100, 1), '%') AS 'annual change'
FROM t_lubos_polak_project_sql_primary_final tpf 
JOIN t_lubos_polak_project_sql_primary_final tpf1 ON tpf.`year` = tpf1.`year` + 1
WHERE tpf.product_name = tpf1.product_name 
ORDER BY tpf.product_name,  tpf.`year`;


-- Dotaz k zobrazení minim a maxim procentuálních meziročních změn:
SELECT 
    product_name,
    MIN(per.percentage_change) AS 'min_annual_percentage_change',
    MAX(per.percentage_change) AS 'max_annual_percentage_change'
    -- MAX(per.percentage_change)-MIN(per.percentage_change)
FROM (
    SELECT 
        tpf.product_name,
        tpf.`year`,
        tpf.product_price,
        tpf1.product_price AS 'product_price_in_previous_year',
        ROUND(((tpf.product_price / tpf1.product_price) * 100)-100, 1) AS 'percentage_change'
    FROM t_lubos_polak_project_sql_primary_final tpf
    JOIN t_lubos_polak_project_sql_primary_final tpf1 ON tpf.`year` = tpf1.`year` + 1
    WHERE tpf.product_name = tpf1.product_name 
	) per
GROUP BY per.product_name
ORDER BY (MAX(per.percentage_change)-MIN(per.percentage_change));