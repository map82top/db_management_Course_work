CREATE OR REPLACE FUNCTION create_market_human(market_name varchar(60), open_time timetz, clost_time timetz, currency_name varchar(10))
    RETURNS void AS
$BODY$
DECLARE
    currency_id smallint;
BEGIN
    SELECT id INTO currency_id FROM currency cur WHERE cur.currency_name = create_market_human.currency_name;

    PERFORM create_market(market_name, open_time, clost_time, currency_id);
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_market(market_name varchar(60), open_time timetz, clost_time timetz, currency_id smallint)
    RETURNS void AS
$BODY$
DECLARE
    currency RECORD;
BEGIN
    SELECT * INTO currency FROM currency cur WHERE cur.id = create_market.currency_id;

    IF currency IS NULL THEN
        RAISE EXCEPTION 'Currency not found';
    END IF;

    INSERT INTO market (name, open_time, close_time, currency, status) VALUES(market_name, open_time, clost_time, currency_id, DEFAULT);
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION delete_market_human(market_name varchar(60))
    RETURNS void AS
$BODY$
DECLARE
    market_id int;
BEGIN
    SELECT * INTO market_id FROM market m WHERE m.name = market_name;
    PERFORM delete_market(market_id);
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION delete_market(market_id int)
    RETURNS void AS
$BODY$
DECLARE
    market RECORD;
    instrument RECORD;
    market_broker RECORD;
BEGIN
    SELECT * INTO market FROM market m WHERE m.id = delete_market.market_id;

     IF market IS NULL THEN
        RAISE EXCEPTION 'Market not found';
     END IF;

     IF market.deleted_time IS NOT NULL THEN
        RAISE EXCEPTION 'Market is deleted';
     END IF;

     IF market.status != 'close' THEN
        RAISE EXCEPTION 'Market not closed';
     END IF;

     FOR instrument IN
        SELECT * FROM instrument inst WHERE inst.market_id = market.id
     LOOP
        PERFORM delete_instrument(instrument.id);
     END LOOP;

     FOR market_broker IN
        SELECT * FROM market_broker mb WHERE mb.market_id = market.id
     LOOP
        PERFORM delete_broker_from_market(mb.broker_id, market.id);
     END LOOP;

     UPDATE market SET market.deleted_time = CURRENT_TIMESTAMP WHERE market.id = delete_market.market_id;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION open_market_human(market_name varchar(60))
    RETURNS void AS
$BODY$
DECLARE
    market_id int;
BEGIN
    SELECT id INTO market_id FROM market m WHERE m.name = open_market_human.market_name;

    PERFORM open_market(market_id);
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION open_market(market_id int)
    RETURNS void AS
$BODY$
DECLARE
     market RECORD;
BEGIN
     SELECT * INTO market FROM market m WHERE m.id = delete_market.market_id;

     IF market IS NULL THEN
        RAISE EXCEPTION 'Market not found';
     END IF;

     IF market.deleted_time IS NOT NULL THEN
        RAISE EXCEPTION 'Market is deleted';
     END IF;

     IF market.status != 'close' THEN
        RAISE EXCEPTION 'Market not closed';
     END IF;

     UPDATE market m SET m.status = 'open' WHERE m.id = open_market.market_id;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION close_market_human(market_name varchar(60))
    RETURNS void AS
$BODY$
DECLARE
    market_id int;
BEGIN
    SELECT id INTO market_id FROM market m WHERE m.name = open_market_human.market_name;

    PERFORM close_market(market_id);
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION close_market(market_id int)
    RETURNS void AS
$BODY$
DECLARE
     market RECORD;
     order_id bigint;
BEGIN
     SELECT * INTO market FROM market m WHERE m.id = delete_market.market_id;

     IF market IS NULL THEN
        RAISE EXCEPTION 'Market not found';
     END IF;

     IF market.deleted_time IS NOT NULL THEN
        RAISE EXCEPTION 'Market is deleted';
     END IF;

     IF market.status = 'close' THEN
        RAISE EXCEPTION 'Market is closed';
     END IF;

     FOR order_id IN
        SELECT o.id FROM instrument inst JOIN order_ o ON inst.id = o.instrument_id
        WHERE inst.deleted_time IS NULL AND inst.market_id = market.id
            AND o.cancel_time IS NULL AND o.status != 'cancelled' AND o.status != 'filled'
     LOOP
        PERFORM cancel_order(order_id);
     END LOOP;

     UPDATE market m SET m.status = 'close' WHERE m.id = open_market.market_id;
END;
$BODY$
    LANGUAGE plpgsql;
