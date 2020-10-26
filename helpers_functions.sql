CREATE OR REPLACE FUNCTION get_instrument(instrument_id int)
    RETURNS instrument AS
$BODY$
DECLARE
    instrument RECORD;
BEGIN
    SELECT * INTO instrument FROM instrument inst WHERE inst.id = instrument_id;

     IF instrument IS NULL THEN
        RAISE EXCEPTION 'Instrument % not found', instrument_id;
     END IF;

     IF instrument.deleted_time IS NOT NULL THEN
        RAISE EXCEPTION 'Instrument % is deleted', instrument_id;
     END IF;

     RETURN instrument;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_instrument_template(instrument_template_code varchar(6))
    RETURNS instrument_template AS
$BODY$
DECLARE
    instrument_template RECORD;
BEGIN
    SELECT * INTO instrument_template FROM instrument_template it WHERE it.instrument_code = instrument_template_code;

     IF instrument_template IS NULL THEN
        RAISE EXCEPTION 'Instrument template % not found', instrument_template_code;
     END IF;

     IF instrument_template.deleted_time IS NOT NULL THEN
        RAISE EXCEPTION 'Instrument template % is deleted', instrument_template_code;
     END IF;

     RETURN instrument_template;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_order(order_id bigint)
    RETURNS order_ AS
$BODY$
DECLARE
    order_r RECORD;
BEGIN
    SELECT * INTO order_r FROM order_ o WHERE o.id = order_id;

    IF order_r IS NULL THEN
        RAISE EXCEPTION 'Order % not found', order_id;
     END IF;

     IF order_r.cancel_time IS NOT NULL OR order_r.status = 'cancelled' THEN
        RAISE EXCEPTION 'Order % is cancelled', order_id;
     END IF;

     IF order_r.status = 'filled' THEN
        RAISE EXCEPTION 'Order % is filled', order_id;
     END IF;

     RETURN order_r;
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_trader(trader_id int)
    RETURNS trader AS
$BODY$
DECLARE
    trader RECORD;
BEGIN
    SELECT * INTO trader FROM trader t WHERE t.id = trader_id;

     IF trader IS NULL THEN
        RAISE EXCEPTION 'Trader % not found', trader_id;
     END IF;

     IF trader.deleted_time IS NOT NULL THEN
        RAISE EXCEPTION 'Trader % is deleted', trader_id;
     END IF;

     RETURN trader;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_broker(broker_id int)
    RETURNS broker AS
$BODY$
DECLARE
    broker RECORD;
BEGIN
    SELECT * INTO broker FROM broker b WHERE b.id = broker_id;

    IF broker IS NULL THEN
        RAISE EXCEPTION 'Broker % not found', broker_id;
    END IF;

    IF broker.deleted_time IS NOT NULL THEN
       RAISE EXCEPTION 'Broker % is deleted', broker_id;
    END IF;

    RETURN broker;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_account(account_number int)
    RETURNS account AS
$BODY$
DECLARE
    account RECORD;
BEGIN
    SELECT * INTO account FROM account ac WHERE ac.number = account_number;

     IF account IS NULL THEN
        RAISE EXCEPTION 'Account % not found', account_number;
     END IF;

     IF account.deleted_time IS NOT NULL THEN
        RAISE EXCEPTION 'Account % is deleted', account_number;
     END IF;

     RETURN account;
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_market(market_id int)
    RETURNS market AS
$BODY$
DECLARE
    market RECORD;
BEGIN
    SELECT * INTO market FROM market m WHERE m.id = market_id;

    IF market IS NULL THEN
       RAISE EXCEPTION 'Market % not found', market_id;
    END IF;

    IF market.deleted_time IS NOT NULL THEN
      RAISE EXCEPTION 'Market % is deleted', market_id;
    END IF;

    RETURN market;
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION currency_exist(currenty_id smallint)
    RETURNS void AS
$BODY$
DECLARE
BEGIN
    IF NOT EXISTS (SELECT * FROM currency cur WHERE cur.id = currenty_id) THEN
        RAISE EXCEPTION 'Currency % not found', currenty_id;
     END IF;
END;
$BODY$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION time_zone_exist(time_zone_id smallint)
    RETURNS void AS
$BODY$
DECLARE
BEGIN
     IF NOT EXISTS (SELECT * FROM time_zone tz WHERE tz.id = time_zone_id) THEN
        RAISE EXCEPTION 'Time zone % not found', time_zone_id;
     END IF;
END;
$BODY$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION country_exist(country_id smallint)
    RETURNS void AS
$BODY$
DECLARE
BEGIN
    IF NOT EXISTS (SELECT * FROM country cnt WHERE cnt.id = country_id) THEN
        RAISE EXCEPTION 'Country % not found', country_id;
     END IF;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_market_broker(market_id int, broker_id int)
    RETURNS market_broker AS
$BODY$
DECLARE
    market_broker RECORD;
    market_broker_account RECORD;
BEGIN
     SELECT * INTO market_broker FROM market_broker mb WHERE mb.broker_id = get_market_broker.broker_id AND get_market_broker.market_id = mb.market_id;

     IF market_broker IS NULL THEN
        RAISE EXCEPTION 'Broker % not assign to order`s market %',  broker_id, market_id;
     END IF;

     RETURN market_broker;
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION iif_sql(boolean, anyelement, anyelement) returns anyelement as
$body$ select case $1 when true then $2 else $3 end $body$
LANGUAGE sql IMMUTABLE;