CREATE OR REPLACE FUNCTION create_account_human(first_name varchar(20), last_name varchar(25), broker_name varchar(100), type_account type_account, currency varchar(10))
    RETURNS void AS
$BODY$
DECLARE
    currency_id smallint;
    trader_id int;
    broker_id int;
BEGIN
    SELECT id INTO currency_id FROM currency cur WHERE cur.currency_name = create_account_human.currency;
    SELECT id INTO trader_id FROM trader tr WHERE tr.first_name = create_account_human.first_name and tr.last_name = create_account_human.last_name;
    SELECT id INTO broker_id FROM broker br WHERE br.name = create_account_human.broker_name;

    PERFORM create_account(trader_id, broker_id, type_account, currency_id);
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_account(trader_id int, broker_id int, type_account type_account, currency_id smallint)
    RETURNS int AS
$BODY$
DECLARE
     trader RECORD;
     broker RECORD;
     account_id int;
BEGIN
     IF trader_id IS NOT NULL THEN
        SELECT * INTO trader FROM get_trader(create_account.trader_id);
     END IF;

     SELECT * INTO broker FROM get_broker(create_account.broker_id);

     PERFORM currency_exist(currency_id);

     INSERT INTO account (current_funds, trader_code, broker_code, type_account, type_currency) VALUES(DEFAULT, trader_id, broker_id, type_account, currency_id)
     RETURNING number into account_id;


     RETURN(SELECT account_id);
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION delete_account(account_id int)
    RETURNS void AS
$BODY$
DECLARE
    account RECORD;
BEGIN
    SELECT * INTO account FROM get_account(delete_account.account_id);

     IF account.current_funds < 0::money THEN
        RAISE EXCEPTION 'Account`s current fund is less then zero. Impossible delete such account.';
     END IF;

     IF (SELECT COUNT(*) FROM order_ o WHERE o.account = account.number AND o.cancel_time IS NULL AND (o.status = 'cancelled' OR o.status = 'partfilled')) > 0 THEN
        RAISE EXCEPTION 'Account has active orders. Impossible delete such account.';
     END IF;

     IF account.current_funds > 0::money THEN
        INSERT INTO movement_fund (amount, type, initiator_type, account_id, description) VALUES (account.current_funds, 'output', 'system', account.number, 'Deleted account');
     END IF;

     UPDATE account ac SET deleted_time = now(), current_funds = 0 WHERE ac.number = delete_account.account_id;
END;
$BODY$
    LANGUAGE plpgsql;