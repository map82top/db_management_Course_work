CREATE OR REPLACE FUNCTION create_instrument_human(lot_size int, instrument_template_code varchar(6), market_name varchar(60), trading_start_date date)
    RETURNS void AS
$BODY$
DECLARE
    market_id smallint;
BEGIN
    SELECT id INTO market_id FROM market m WHERE m.name = market_name;

    PERFORM create_instrument(lot_size, instrument_template_code, market_id, trading_start_date);
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_instrument(lot_size int, instrument_template_code varchar(6), market_id smallint, trading_start_date date)
    RETURNS void AS
$BODY$
DECLARE
    instrument_template RECORD;
    market RECORD;
BEGIN
    SELECT * INTO instrument_template FROM instrument_template it WHERE it.instrument_code = create_instrument.instrument_template_code;

    IF instrument_template IS NULL THEN
        RAISE EXCEPTION 'Instrument template not found';
    END IF;

    IF instrument_template.deleted_time IS NOT NULL THEN
        RAISE EXCEPTION 'Instrument template is deleted';
    END IF;

    SELECT * INTO market FROM market m WHERE m.id = create_instrument.market_id;

    IF market IS NULL THEN
        RAISE EXCEPTION 'Market not found';
    END IF;

    IF market.deleted_time IS NOT NULL THEN
        RAISE EXCEPTION 'Market is deleted';
    END IF;

    IF trading_start_date IS NULL THEN
        trading_start_date = CURRENT_TIMESTAMP::date + interval '1 day';
    ELSE
        IF trading_start_date < CURRENT_TIMESTAMP::date + interval '1 day' THEN
            RAISE EXCEPTION 'Trading start date must be more than current date';
        END IF;
    END IF;

    IF market.status != 'close' THEN
        RAISE EXCEPTION 'Market not closed';
    END IF;

    INSERT INTO instrument (lot_size, trading_start_date, instrument_template_code, market_id)
                VALUES(lot_size, trading_start_date, instrument_template_code, market_id);
END;
$BODY$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_instrument_human(instrument_template_code varchar(6), market_name varchar(60))
    RETURNS void AS
$BODY$
DECLARE
    instrument_id int;
    instrument_template RECORD;
    market RECORD;
BEGIN
    SELECT * INTO instrument_template FROM instrument_template it WHERE it.instrument_code = delete_instrument_human.instrument_template_code;
    SELECT * INTO market FROM market m WHERE m.id = delete_instrument_human.market_name;
    SELECT id INTO instrument_id FROM instrument inst WHERE inst.market_id = market_id AND instrument_template.instrument_code = inst.instrument_template_code;

    PERFORM delete_instrument(instrument_id);
END;
$BODY$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_instrument(id int)
    RETURNS void AS
$BODY$
DECLARE
    instrument RECORD;
    market RECORD;
BEGIN
    SELECT * INTO instrument FROM instrument ins WHERE ins.id = delete_instrument.id;

    IF instrument IS NULL THEN
        RAISE EXCEPTION 'Instrument not found';
    END IF;

    IF instrument.delete_date IS NOT NULL THEN
        RAISE EXCEPTION 'Instrument is deleted';
    END IF;

    SELECT *  INTO market FROM market m WHERE m.id = instrument.market_id;

    IF market.status != 'close' THEN
        RAISE EXCEPTION 'Market not closed';
    END IF;

    UPDATE instrument inst SET delete_date = CURRENT_TIMESTAMP WHERE inst.id = delete_instrument.id;

END;
$BODY$
    LANGUAGE plpgsql;