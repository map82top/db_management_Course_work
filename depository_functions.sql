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



CREATE OR REPLACE FUNCTION initial_placement(instument_id int, price money, quantity int, account_number int)
    RETURNS void AS
$BODY$
DECLARE
    account RECORD;
    instrument_ RECORD;
    instrument_template_ RECORD;
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

     IF price * quantity > account.current_funds THEN
        RAISE EXCEPTION 'Insufficient funds on the account';
     END IF;

     SELECT * INTO instrument_ FROM instrument inst WHERE inst.id = instument_id;

     IF instrument_ IS NULL THEN
        RAISE EXCEPTION 'Instrument not found';
     END IF;

     IF instrument_.delete_date THEN
        RAISE EXCEPTION 'Instrument is deleted';
     END IF;


     SELECT * INTO instrument_template_ FROM instrument_template WHERE instrument_code = instrument_.instrument_template_code;

     IF instrument_template_ IS NULL THEN
        RAISE EXCEPTION 'Instrument template not found';
     END IF;

     IF instrument_template_.delete_date THEN
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