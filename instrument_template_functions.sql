CREATE OR REPLACE FUNCTION add_instrument_template_human(instrument_code varchar(6), short_name varchar(20), long_name varchar(256), coupon_rate numeric(2), 
coupon_amount numeric(2), coupon_payment_frequency smallint, isin varchar(12), emission_volume bigint, nominal_price numeric(2), instrument_type instrument_type,
currency_name varchar(10)) RETURNS void AS
  $BODY$
DECLARE
  currency_id smallint;
BEGIN
    select id into currency_id from currency where add_instrument_template_human.currency_name = currency.currency_name;

    PERFORM add_instrument_template(instrument_code, short_name, long_name, coupon_rate, coupon_amount, coupon_payment_frequency, isin, emission_volume,
                                    nominal_price, instrument_type, currency_id);
END;
$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_instrument_template(instrument_code varchar(6), short_name varchar(20), long_name varchar(256), coupon_rate numeric(2), 
coupon_amount numeric(2), coupon_payment_frequency smallint, isin varchar(12), emission_volume bigint, nominal_price numeric(2), instrument_type instrument_type,
currency_id smallint) RETURNS void AS
  $BODY$
BEGIN
  IF NOT EXISTS (SELECT 1 from currency where currency.id = currency_id) THEN
    RAISE EXCEPTION 'Specified currency does not exists';
  END IF;

  INSERT INTO instrument_template(instrument_code, short_name, long_name, coupon_rate, coupon_amount, coupon_payment_frequency, isin, emission_volume, nominal_price, 
  instrument_type, currency, emission_date) 
  VALUES(instrument_code, short_name, long_name, coupon_rate, coupon_amount, coupon_payment_frequency, isin, emission_volume, 
  nominal_price, instrument_type, currency_id, CURRENT_TIMESTAMP);

END;
$BODY$
  LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION remove_instrument_template(instrument_code varchar(6)) RETURNS void AS
    $BODY$
DECLARE
    market RECORD;
    instrument_ RECORD;
BEGIN
    IF NOT EXISTS(SELECT 1 from instrument_template where instrument_template.instrument_code = remove_instrument_template.instrument_code) THEN 
        RAISE EXCEPTION 'Instrument does not exist';
    END IF;

    FOR market in
        SELECT * from market
    LOOP
        IF(market.close_time > CURRENT_TIME) THEN
            RAISE EXCEPTION 'At least market % is not closed', market.name;
        END IF;
    END LOOP;

    raise notice 'Value: %', instrument_code;
    FOR instrument_ in 
        SELECT * from instrument where instrument.instrument_template_id = instrument_code
    LOOP
        PERFORM delete_instrument(instrument_.id);
    END LOOP;

    UPDATE instrument_template SET deleted_time = now() where instrument_template.instrument_code = remove_instrument_template.instrument_code;

END;
$BODY$
LANGUAGE plpgsql;