CREATE OR REPLACE FUNCTION create_trader_human(first_name varchar(20), last_name varchar(25), time_zone varchar(5), country varchar(50), broker_name varchar(100), currency varchar(10))
    RETURNS void AS
$BODY$
DECLARE
    time_zone_id smallint;
    country_id smallint;
    currency_id smallint;
    trader_id int;
    broker_id int;
BEGIN
     SELECT id INTO time_zone_id FROM time_zone tz WHERE tz.utc_time_zone = create_trader_human.time_zone;
     SELECT id INTO country_id FROM country c WHERE c.country_name = create_trader_human.country;
     SELECT id INTO currency_id FROM currency cur WHERE cur.currency_name = create_trader_human.currency;
     SELECT id INTO broker_id FROM broker b WHERE b.name = create_trader_human.broker_name;

     PERFORM create_trader(first_name, last_name, time_zone_id, country_id, broker_id, currency_id);
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_trader(first_name varchar(20), last_name varchar(25), time_zone_id smallint, country_id smallint, broker_id int, currency_id smallint)
    RETURNS void AS
$BODY$
DECLARE
    trader_id int;
    broker RECORD;
BEGIN
     SELECT * INTO broker FROM broker b WHERE b.id = create_trader.broker_id;

     IF broker IS NULL THEN
        RAISE EXCEPTION 'Broker not found';
     END IF;

     IF broker.deleted_time IS NOT NULL THEN
        RAISE EXCEPTION 'Broker is deleted';
     END IF;

     IF NOT EXISTS (SELECT * FROM currency cur WHERE cur.id = create_trader.currency_id) THEN
        RAISE EXCEPTION 'Currency not found';
     END IF;

     IF NOT EXISTS (SELECT * FROM country cnt WHERE cnt.id = create_trader.country_id) THEN
        RAISE EXCEPTION 'Country not found';
     END IF;

     IF NOT EXISTS (SELECT * FROM time_zone tz WHERE tz.id = create_trader.time_zone_id) THEN
        RAISE EXCEPTION 'Time zone not found';
     END IF;

     INSERT INTO trader(first_name, last_name, timezone, country) VALUES(first_name, last_name, time_zone_id, country_id)
     RETURNING id INTO trader_id;


     PERFORM create_account(trader_id, broker_id, 'debit', currency_id);
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION delete_trader(trader_id int, broker_id int)
    RETURNS void AS
$BODY$
DECLARE
    trader RECORD;
    account RECORD;
BEGIN
     SELECT * INTO trader FROM trader tr WHERE tr.id = delete_trader.trader_id;

     IF trader IS NULL THEN
        RAISE EXCEPTION 'Trader not found';
     END IF;

     IF trader.deleted_time IS NOT NULL THEN
        RAISE EXCEPTION 'Trader is deleted';
     END IF;

     FOR account IN
        SELECT * FROM account ac WHERE
        ac.trader_code = delete_trader.trader_id AND delete_trader.broker_id IS NULL
        OR
        ac.trader_code = delete_trader.trader_id AND ac.broker_code = delete_trader.broker_id
     LOOP
        PERFORM delete_account(account.number);
     END LOOP;

     UPDATE trader tr SET deleted_time = now() WHERE tr.id = trader_id;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION delete_trader_human(first_name varchar(20), last_name varchar(25))
    RETURNS void AS
$BODY$
DECLARE
    trader_id int;
BEGIN
    SELECT id INTO trader_id FROM trader tr WHERE tr.first_name = delete_trader_human.first_name and tr.last_name = delete_trader_human.last_name;

    PERFORM delete_trader(trader_id, NULL);
END;
$BODY$
    LANGUAGE plpgsql;