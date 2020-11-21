INSERT INTO instrument_template(instrument_code, short_name, long_name, coupon_rate, coupon_amount, coupon_payment_frequency, isin, emission_volume, nominal_price,
                    instrument_type, currency, emission_date, deleted_time)
    VALUES('110050', 'Fgz', 'Obotljqirijpufbfklmtqfpthojpvsiwvzftgphfcywqfuykbn', 1.0, 1.0, 1::smallint, 'vxqshdALGGI2', 1000,
                    2.0, 'bond', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

SELECT instrument_code, short_name, long_name, deleted_time FROM instrument_template WHERE instrument_code = '110050';

INSERT INTO instrument_template(instrument_code, short_name, long_name, coupon_rate, coupon_amount, coupon_payment_frequency, isin, emission_volume, nominal_price,
                    instrument_type, currency, emission_date)
    VALUES('110050', 'Fgz', 'Obotljqirijpufbfklmtqfpthojpvsiwvzftgphfcywqfuykbn', 1.0, 1.0, 1::smallint, 'vxqshdALGGI2', 1000,
                    2.0, 'bond', 1, CURRENT_TIMESTAMP);

SELECT instrument_code, short_name, long_name, deleted_time FROM instrument_template WHERE  instrument_code = '110050';

UPDATE instrument_template SET deleted_time = CURRENT_TIMESTAMP, short_name='APL' WHERE instrument_code = '110050';

SELECT instrument_code, short_name, long_name, deleted_time FROM instrument_template WHERE instrument_code = '110050';

DELETE FROM instrument_template WHERE instrument_code = '110050';

SELECT instrument_code, short_name, long_name, deleted_time FROM instrument_template WHERE instrument_code = '110050';

SELECT * FROM current_prices;

SELECT * FROM commision_income_by_broker_id(1);

SELECT * FROM total_income_for_account(1);
