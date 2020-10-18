CREATE OR REPLACE FUNCTION make_trader_movement_fund(amount money, direction direction, account_number int, description varchar(256))
    RETURNS void AS
$BODY$
DECLARE
    account RECORD;
    trader_ RECORD;
BEGIN

    SELECT * INTO account FROM account a WHERE a.number = account_number;

     IF account IS NULL THEN
        RAISE EXCEPTION 'Account not found';
     END IF;

     IF account.deleted_time THEN
        RAISE EXCEPTION 'Account is deleted';
     END IF;

     IF account.trader_code IS NULL THEN
        RAISE EXCEPTION 'FOR trader movement fund trader account is required';
     END IF;
    

    SELECT * INTO trader_ FROM trader t WHERE t.id = account.trader_code;
    
     IF trader_ IS NULL THEN
        RAISE EXCEPTION 'Trader not found';
     END IF;

     IF trader_.deleted_time THEN
        RAISE EXCEPTION 'Trader is deleted';
     END IF;

    PERFORM make_movement_fund(amount, direction, trader_.id, 'trader', account.number, description);
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION make_broker_movement_fund(amount money, direction direction, account_number int, description varchar(256))
    RETURNS void AS
$BODY$
DECLARE
    account RECORD;
    broker RECORD;
BEGIN
    SELECT * INTO account FROM account a WHERE a.number = account_number;

     IF account IS NULL THEN
        RAISE EXCEPTION 'Account not found';
     END IF;

     IF account.deleted_time THEN
        RAISE EXCEPTION 'Account is deleted';
     END IF;

     IF account.broker_code IS NULL THEN
        RAISE EXCEPTION 'FOR broker movement fund broker account is required';
     END IF;

     SELECT * INTO broker FROM broker b WHERE b.id = account.broker_code;

     IF broker IS NULL THEN
        RAISE EXCEPTION 'Broker not found';
     END IF;

     IF broker.deleted_time THEN
        RAISE EXCEPTION 'Broker is deleted';
     END IF;

    PERFORM make_movement_fund(amount, direction, broker.id, 'broker', account.number, description);
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION make_movement_fund(amount money, direction direction, initiator_id int, initiator_type initiator_type, account_number int, description varchar(256))
    RETURNS void AS
$BODY$
DECLARE
    account RECORD;
    broker RECORD;
    trader RECORD;
    new_current_funds money;
    trader_initiator_id int;
    broker_initiator_id int;
BEGIN 
    IF amount <= 0::money THEN
        RAISE EXCEPTION 'Amount must be more then zero';
    END IF;

    SELECT * INTO account FROM account a WHERE a.number = account_number;

    IF account IS NULL THEN
        RAISE EXCEPTION 'Account not found';
    END IF;

    IF account.deleted_time THEN
       RAISE EXCEPTION 'Account is deleted';
    END IF;

    IF direction = 'output' THEN
         new_current_funds = account.current_funds - amount;
    ELSIF direction = 'input' THEN
         new_current_funds = account.current_funds + amount;
    ELSE
        RAISE EXCEPTION 'Unknown type of movement';
    END IF;

    IF initiator_type = 'broker' THEN
        IF initiator_id IS NULL THEN
            RAISE EXCEPTION 'Initiator for broker movement fund can`t be NULL';
        END IF;

        SELECT * INTO broker FROM broker b WHERE b.id = initiator_id;

        IF broker IS NULL THEN
            RAISE EXCEPTION 'Broker not found';
        END IF;

        IF broker.deleted_time THEN
            RAISE EXCEPTION 'Broker is deleted';
        END IF;

        broker_initiator_id = initiator_id;

    ELSIF initiator_type = 'trader' THEN
         IF initiator_id IS NULL THEN
            RAISE EXCEPTION 'Initiator for trader movement fund can`t be NULL';
        END IF;

        SELECT * INTO trader FROM trader t WHERE t.id = initiator_id;

        IF trader IS NULL THEN
            RAISE EXCEPTION 'Trader not found';
        END IF;

        IF trader.deleted_time THEN
            RAISE EXCEPTION 'Trader is deleted';
        END IF;

        trader_initiator_id = initiator_id;
    ELSIF initiator_type = 'system' THEN
        IF initiator_id IS NOT NULL THEN
            RAISE EXCEPTION 'For system movement fund initiator must be NULL';
        END IF;

    ELSE
        RAISE EXCEPTION 'Unknown initiator_type';
    END IF;

    IF new_current_funds < 0::money  AND initiator_type = 'trader' AND direction = 'output' THEN
        RAISE EXCEPTION 'From account is impossible take out more fund then has';
    END IF;

    IF new_current_funds < 0::money AND account.type_account = 'debit' AND direction = 'output' THEN
        RAISE EXCEPTION 'From debit account is impossible take out more fund then has';
    END IF;

    UPDATE account a SET current_funds = new_current_funds WHERE a.number = account_number;

    INSERT INTO movement_fund (amount, direction, trader_initiator_id, broker_initiator_id, initiator_type, account_id, description)
        VALUES(amount, direction, trader_initiator_id, broker_initiator_id, initiator_type, account_number, description);
END;
$BODY$
    LANGUAGE plpgsql;