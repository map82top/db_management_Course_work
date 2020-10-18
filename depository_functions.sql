CREATE OR REPLACE FUNCTION initial_placement_human(price money, quantity int, broker_name varchar(100), market_name varchar(60), instrument_template_code_ varchar(6))
   RETURNS void AS
$BODY$
DECLARE
   account_number SMALLINT;
   instrument_id int;
   market_i int;
   broker_id_ int;
BEGIN
   SELECT id into broker_id_ from broker where name = broker_name;

   IF broker_id_ IS NULL THEN
      RAISE EXCEPTION 'Broker % does not exist', broker_name;
   END IF;

   SELECT market.id into market_i from market where market.name = market_name;

   IF market_i IS NULL THEN
      RAISE EXCEPTION 'Market % does not exist', market_name;
   END IF;

   IF NOT EXISTS( SELECT 1 from instrument_template where instrument_template.instrument_code = instrument_template_code_) THEN
      RAISE EXCEPTION 'Instrument template % does not exist', instrument_template;
   END IF;

   SELECT instrument.id into instrument_id from instrument where instrument.market_id = market_i 
                                                               and instrument.instrument_template_code = instrument_template_code_;

   SELECT account_id into account_number from market_broker where market_id = (select instrument.market_id from instrument where id = instrument_id) 
   and market_broker.broker_id = broker_id_;


   PERFORM initial_placement(instrument_id, price, quantity, account_number);
END;
$BODY$
    LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION initial_placement(instrument_id int, price money, quantity int, account_number int)
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

     IF price * quantity > account.current_funds THEN
        RAISE EXCEPTION 'Insufficient funds on the account';
     END IF;

     SELECT * INTO instrument FROM get_instrument(instrument_id);
     SELECT * INTO instrument_template FROM get_instrument_template(instrument.instrument_template_code);

     SELECT SUM(CASE WHEN d.direction = 'input' THEN d.quantity ELSE -(d.quantity) END) INTO instruments_in_system FROM depository d WHERE d.instrument_id = initial_placement.instrument_id;

     IF instruments_in_system + quantity > instrument_template.emission_volume THEN
        RAISE EXCEPTION 'Instruments in system can`t be more then emission volume';
     END IF;

     PERFORM make_broker_movement_fund (price * quantity, 'output', account_number, 'Initial placement');

     INSERT INTO depository (price, quantity, direction, instrument_id, account_number) VALUES(price, quantity, 'input', instrument_id, account_number);

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

     RETURN (SELECT COALESCE(SUM(CASE WHEN d.direction = 'input' THEN d.quantity ELSE -d.quantity END), 0) FROM depository d
     WHERE d.instrument_id = count_instrument_on_account.instrument_id
        AND d.account_number = count_instrument_on_account.account_number);
END;
$BODY$
LANGUAGE plpgsql;