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
    PERFORM currency_exist(currency_id);

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
    instrument_template RECORD;
BEGIN
    SELECT * INTO instrument_template FROM get_instrument_template(instrument_code);

    FOR market in
        SELECT * from market
    LOOP
        IF(market.status = 'close') THEN
            RAISE EXCEPTION 'Market % is not closed', market.name;
        END IF;
    END LOOP;

    raise notice 'Value: %', instrument_code;
    FOR instrument_ in 
        SELECT * from instrument where instrument.instrument_template_code = instrument_code
    LOOP
        PERFORM delete_instrument(instrument_.id);
    END LOOP;

    UPDATE instrument_template SET deleted_time = now() where instrument_template.instrument_code = remove_instrument_template.instrument_code;

END;
$BODY$
LANGUAGE plpgsql;