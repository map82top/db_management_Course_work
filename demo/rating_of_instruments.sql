\echo 'Reference data:'
SELECT it.short_name sn, 
    (CASE 
        WHEN SUM(t.quantity) > 0 THEN SUM(t.quantity)
        ELSE 0
    END) as volume 
    FROM instrument i 
            JOIN instrument_template it on i.instrument_template_code = it.instrument_code
            left JOIN order_ o on i.id = o.instrument_id
            left JOIN trade t on t.bid_order_id = o.id
            GROUP BY it.short_name;   

\echo 'Analytic data: '
SELECT * FROM rating_of_instruments(30, 15, 5, 2.5);