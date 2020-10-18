CREATE OR REPLACE FUNCTION initial_placement(instument_id int, price money, quantity int, account_number int)
    RETURNS void AS
$BODY$
DECLARE
    account RECORD;
    instrument RECORD;
    instrument_template RECORD;
    instruments_in_system bigint;
BEGIN
     SELECT * INTO account FROM get_account(account_number);

     IF account.trader_code IS NOT NULL THEN
        RAISE EXCEPTION 'Owner of account must be a broker';
     END IF;

     IF price * quantity < account.current_funds IS NOT NULL THEN
        RAISE EXCEPTION 'Insufficient funds on the account';
     END IF;

     SELECT * INTO instrument FROM get_instrument(instrument_id);
     SELECT * INTO instrument_template FROM get_instrument_template(instument.instrument_template_code);

     SELECT SUM(CASE WHEN d.direction = 'input' THEN d.quantity ELSE -d.quanity END) INTO instruments_in_system FROM depository d WHERE d.instrument_id = instument_id;

     IF instruments_in_system + quantity > instrument_template.emission_volume THEN
        RAISE EXCEPTION 'Instruments in system can`t be more then emission volume';
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
     SELECT * INTO account FROM get_account(account_number);

     SELECT * INTO instrument FROM get_instrument(instrument_id);

     RETURN (SELECT COALESCE(SUM(CASE WHEN d.direction = 'input' THEN d.quantity ELSE -d.quanity END), 0) FROM depository d
     WHERE d.instrument_id = count_instrument_on_account.instrument_id
        AND d.account_number = count_instrument_on_account.account_number);
END;
$BODY$
LANGUAGE plpgsql;