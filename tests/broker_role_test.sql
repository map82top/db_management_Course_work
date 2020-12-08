\echo '==================== TEST 1 ======================'
\echo 'Create INSTRUMENT TEMPLATE with deleted_time IS NOT NULL'
\echo 'Instrument code - 110050'
\echo 'Instrument short name -  Fgz'
\echo 'Instrument long name -  Obotljqirijpufbfklmtqfpthojpvsiwvzftgphfcywqfuykbn'
\echo 'Coupon rate -  1.0'
\echo 'Coupon amount -  1.0'
\echo 'Coupon payment frequency -  vxqshdALGGI2'
\echo 'ISIN -  1'
\echo 'Emission volume -  1000'
\echo 'Nominal price -  2.0'
\echo 'Instrument type -  bond'
\echo 'Currency -  1'
SELECT * FROM currency WHERE id = 1;
\echo 'Emission date -  CURRENT_TIMESTAMP'
\echo 'Deleted time -  CURRENT_TIMESTAMP'

INSERT INTO instrument_template(instrument_code, short_name, long_name, coupon_rate, coupon_amount, coupon_payment_frequency, isin, emission_volume, nominal_price,
                    instrument_type, currency, emission_date, deleted_time)
    VALUES('110050', 'Fgz', 'Obotljqirijpufbfklmtqfpthojpvsiwvzftgphfcywqfuykbn', 1.0, 1.0, 1::smallint, 'vxqshdALGGI2', 1000,
                    2.0, 'bond', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
\echo 'Result'
SELECT instrument_code, short_name, long_name, deleted_time FROM instrument_template WHERE instrument_code = '110050';

\echo '==================== TEST 2 ======================'
\echo 'Create INSTRUMENT TEMPLATE with correct data'
\echo 'Instrument code - 110050'
\echo 'Instrument short name -  Fgz'
\echo 'Instrument long name -  Obotljqirijpufbfklmtqfpthojpvsiwvzftgphfcywqfuykbn'
\echo 'Coupon rate -  1.0'
\echo 'Coupon amount -  1.0'
\echo 'Coupon payment frequency -  vxqshdALGGI2'
\echo 'ISIN -  1'
\echo 'Emission volume -  1000'
\echo 'Nominal price -  2.0'
\echo 'Instrument type -  bond'
\echo 'Currency -  1'
SELECT * FROM currency WHERE id = 1;
\echo 'Emission date -  CURRENT_TIMESTAMP'
INSERT INTO instrument_template(instrument_code, short_name, long_name, coupon_rate, coupon_amount, coupon_payment_frequency, isin, emission_volume, nominal_price,
                    instrument_type, currency, emission_date)
    VALUES('110050', 'Fgz', 'Obotljqirijpufbfklmtqfpthojpvsiwvzftgphfcywqfuykbn', 1.0, 1.0, 1::smallint, 'vxqshdALGGI2', 1000,
                    2.0, 'bond', 1, CURRENT_TIMESTAMP);
\echo 'Result'
SELECT instrument_code, short_name, long_name, deleted_time FROM instrument_template WHERE  instrument_code = '110050';

\echo '==================== TEST 3 ======================'
\echo 'UPDATE INSTRUMENT TEMPLATE record with instrument code - 110050'
\echo 'Instrument short name -  APL'
\echo 'Deleted time -  CURRENT_TIMESTAMP'

UPDATE instrument_template SET deleted_time = CURRENT_TIMESTAMP, short_name='APL' WHERE instrument_code = '110050';

\echo 'Result'
SELECT instrument_code, short_name, long_name, deleted_time FROM instrument_template WHERE instrument_code = '110050';

\echo '==================== TEST 4 ======================'
\echo 'DELETE INSTRUMENT TEMPLATE record with instrument code - 110050'
DELETE FROM instrument_template WHERE instrument_code = '110050';

\echo 'Result'
SELECT instrument_code, short_name, long_name, deleted_time FROM instrument_template WHERE instrument_code = '110050';

\echo '==================== TEST 5 ======================'
\echo 'Access to views'
SELECT * FROM current_prices;

\echo '==================== TEST 6 ======================'
\echo 'Access to functions'
SELECT * FROM commision_income_by_broker_id(1);

\echo '==================== TEST 7 ======================'
\echo 'Cancel order'
\echo 'Order id - 36'

\echo 'Before'
SELECT * FROM get_order(36);

SELECT * FROM cancel_order(36);

\echo 'After'
SELECT * FROM get_order(36);
