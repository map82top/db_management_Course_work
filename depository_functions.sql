CREATE OR REPLACE FUNCTION initial_placement(instument_id int, price money, quantity int, account_number int)
    RETURNS void AS
$BODY$
DECLARE
    account RECORD;
    instrument RECORD;
    instrument_template RECORD;
BEGIN
    SELECT * INTO account FROM account a WHERE a.number = account_number;

     IF account IS NULL THEN
        RAISE EXCEPTION 'Account not found';
     END IF;

     IF account.deleted_time THEN
        RAISE EXCEPTION 'Account is deleted';
     END IF;

     IF account.trader_code IS NOT NULL THEN
        RAISE EXCEPTION 'Owner of account must be a broker';
     END IF;

     IF price * quantity < account.current_funds IS NOT NULL THEN
        RAISE EXCEPTION 'Insufficient funds on the account';
     END IF;

     SELECT * INTO instrument FROM instrument inst WHERE inst.id = instument_id;

     IF instrument IS NULL THEN
        RAISE EXCEPTION 'Instrument not found';
     END IF;

     IF instrument.deleted_time THEN
        RAISE EXCEPTION 'Instrument is deleted';
     END IF;

     SELECT * INTO instrument_template FROM instrument_template it WHERE it.instrument_code = instument.instrument_template_code;

     IF instrument_template IS NULL THEN
        RAISE EXCEPTION 'Instrument template not found';
     END IF;

     IF instrument_template.deleted_time THEN
        RAISE EXCEPTION 'Instrument template is deleted';
     END IF;

     PERFORM make_broker_movement_fund (price * quantity, 'output', account_number, 'Initial placement');

     INSERT INTO depository (price, quantity, direction, instrument_id, account_number) VALUES(price, quantity, 'input', instument_id, account_number);

END;
$BODY$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_instrument_on_account(instrument_id int, account_number int)
    RETURNS bigint AS
$BODY$
DECLARE
    account RECORD;
    instrument RECORD;
BEGIN
    SELECT * INTO account FROM account a WHERE a.number = account_number;

     IF account IS NULL THEN
        RAISE EXCEPTION 'Account not found';
     END IF;

     IF account.deleted_time THEN
        RAISE EXCEPTION 'Account is deleted';
     END IF;

    SELECT * INTO instrument FROM instrument inst WHERE inst.id = instument_id;

     IF instrument IS NULL THEN
        RAISE EXCEPTION 'Instrument not found';
     END IF;

     IF instrument.deleted_time THEN
        RAISE EXCEPTION 'Instrument is deleted';
     END IF;

     RETURN (SELECT SUM(CASE WHEN d.direction = 'input' THEN d.quantity ELSE -d.quanity END) FROM depository d
     WHERE d.instrument_id = count_instrument_on_account.instrument_id
        AND d.account_number = count_instrument_on_account.account_number);
END;
$BODY$
LANGUAGE plpgsql;