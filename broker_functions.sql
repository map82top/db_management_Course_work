-- Create broker functions

CREATE OR REPLACE FUNCTION create_broker_human(legal_entity_identifier varchar(20), utc_time_zone_ varchar(5), country_ varchar(50),
                                         commission numeric(4), actual_address varchar(256), legal_address varchar(256), broker_name varchar(100))
  RETURNS void AS
  $BODY$
DECLARE
  time_zone_id smallint;
  country_id smallint;
BEGIN
  Select id into time_zone_id from time_zone where utc_time_zone = utc_time_zone_;
  Select id into country_id from country where country_name = country_;

  PERFORM create_broker(legal_entity_identifier, time_zone_id, country_id, commission, actual_address, legal_address, broker_name);
END;
$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_broker(legal_entity_identifier varchar(20), utc_time_zone_id smallint, country_id smallint,
                                         commission numeric(4), actual_address varchar(256), legal_address varchar(256), broker_name varchar(100))
  RETURNS void AS
  $BODY$
BEGIN
  IF NOT EXISTS(SELECT id FROM time_zone where id = utc_time_zone_id) THEN
    RAISE EXCEPTION 'Time zone not found';
  END IF;

  IF NOT EXISTS(SELECT * FROM country where id = country_id) THEN
    RAISE EXCEPTION 'Country not found';
  END IF;

  INSERT INTO broker(legal_entity_identifier, timezone, country, commission, actual_address, legal_address, name)
  VALUES(legal_entity_identifier, utc_time_zone_id, country_id, commission, actual_address, legal_address, broker_name);
END;
$BODY$
  LANGUAGE plpgsql;


-- Adding broker to market functions

CREATE OR REPLACE FUNCTION add_broker_to_market_human(broker_name varchar(100), market_name varchar(60), currency_n varchar(10))
  RETURNS void AS
  $BODY$
DECLARE
  broker_id int;
  market_id int;
  currency_id smallint;
BEGIN
  SELECT id into broker_id from broker where broker_name = broker.name;

  SELECT id into market_id from market where market_name = market.name;

  SELECT id into currency_id from currency where currency.currency_name = currency_n;

  raise notice 'Value: % - %', broker_name, broker_id;

  PERFORM add_broker_to_market(broker_id, market_id, currency_id);
END;
$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_broker_to_market(broker_id int, market_id int, currency_id smallint)
  RETURNS void AS
  $BODY$
DECLARE
  broker_ RECORD;
  market_ RECORD;
  currency_ RECORD;
  account_id int;
BEGIN
  SELECT * into broker_ from broker where broker_id = broker.id;

  IF broker_ is null THEN
    RAISE EXCEPTION 'Broker not found';
  END IF;

  IF broker_.deleted_time is not null THEN
    RAISE EXCEPTION 'Broker is deleted';
  END IF;

  SELECT * into market_ from market where market_id = market.id;

  IF market_ is null THEN
    RAISE EXCEPTION 'Market not found';
  END IF;

  IF market_.deleted_time is not null THEN
    RAISE EXCEPTION 'Market is deleted';
  END IF;

  SELECT * into currency_ from currency where currency.id = currency_id;

  IF currency_ is null THEN
    RAISE EXCEPTION 'Currency not found';
  END IF;

  PERFORM create_account(NULL, broker_id, 'debit', currency_id);

  INSERT into market_broker VALUES(broker_id, market_id, currency_id);
END;
$BODY$
  LANGUAGE plpgsql;


-- delete broker from market


CREATE OR REPLACE FUNCTION delete_broker_from_market_human(broker_name varchar(100), market_name varchar(60))
  RETURNS void AS
  $BODY$
DECLARE
  broker_id int;
  market_id int;
BEGIN
  SELECT id into broker_id from broker where broker_name = broker.name;
  SELECT id into market_id from market where market_name = market.name;

  PERFORM delete_broker_from_market(broker_id, market_id);
END;
$BODY$
  LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION delete_broker_from_market(broker_id int, market_id int)
  RETURNS void AS
  $BODY$
DECLARE
  currency_id smallint;
  market_ RECORD;
  broker_ RECORD;
  account RECORD;
BEGIN
  SELECT * into broker_ from broker where broker_id = broker.id;

  IF broker_ is null THEN
    RAISE EXCEPTION 'Broker not found';
  END IF;

  IF broker_.deleted_time is not null THEN
    RAISE EXCEPTION 'Broker is deleted';
  END IF;

  SELECT * into market_ from market where market_id = market.id;

  IF market_ is null THEN
    RAISE EXCEPTION 'Market not found';
  END IF;

  IF market_.deleted_time is not null THEN
    RAISE EXCEPTION 'Market is deleted';
  END IF;

  FOR account IN
    Select account_id from market_broker where market_broker.market_id = market_.id and broker_.id = market_broker.broker_id
  LOOP
    PERFORM delete_account(account.account_id);
  END LOOP;
  DELETE from market_broker mb where mb.market_id = market_.id and broker_.id = mb.broker_id;
END;
$BODY$
  LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION delete_broker_human(broker_name varchar(100)) RETURNS void AS
  $BODY$
DECLARE
  broker_id int;
BEGIN
  select id into broker_id from broker where broker.name = broker_name;
  PERFORM delete_broker(broker_id);
END;
$BODY$
  LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION delete_broker(brokerid int) RETURNS void AS
  $BODY$
DECLARE
  broker_ RECORD;
  market RECORD;
BEGIN
  select * into broker_ from broker where broker.id = brokerid;

  if broker_ is null THEN 
    RAISE EXCEPTION 'Broker not found';
  END IF;

  if broker_.deleted_time is not null THEN 
    RAISE EXCEPTION 'Broker already deleted';
  END IF;

  FOR market IN
    SELECT market_id from market_broker where market_broker.broker_id = brokerid
  LOOP
    PERFORM delete_broker_from_market(brokerid, market.market_id);
  END LOOP;
  
  UPDATE broker SET deleted_time = now() where broker.id = brokerid;
END;
$BODY$
  LANGUAGE plpgsql;
