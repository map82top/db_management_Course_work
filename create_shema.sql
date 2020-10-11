CREATE TYPE type_movement_fund AS ENUM (
  'input',
  'output'
);

CREATE TYPE type_account AS ENUM (
  'debit',
  'credit'
);

CREATE TYPE instrument_type AS ENUM (
  'share',
  'bond'
);

CREATE TYPE order_side AS ENUM (
  'bid',
  'offer'
);

CREATE TYPE order_status AS ENUM (
    'cancelled',
    'partfilld',
    'filled',
    'new'
);

CREATE TYPE initiator_type AS ENUM (
    'broker',
    'trader',
    'system'
);

CREATE TABLE instrument (
        id int PRIMARY KEY,
        delete_date datetime,
        lot_size int,
        trading_start_date datetime,
        instrument_template_id smallint NOT NULL REFERENCES  exchange_db.instrument_template(id),
        market_id smallint NOT NULL REFERENCES exchange_db.market(id)
);

CREATE TABLE exchange_db.instrument_template (
        id int PRIMARY KEY,
        short_name varchar,
        long_name varchar,
        coupon_rate float,
        coupon_amount float,
        coupon_payment_frequency smallint,
        isin varchar,
        maturity_date datetime,
        emission_volume float,
        emission_date datetime,
        delete_date datetime,
        nominal_price float,
        instrument_type instrument_type,
        currency smallint NOT NULL REFERENCES exchange_db.currency(id)
);

CREATE TABLE exchange_db.market (
        id int PRIMARY KEY,
        name varchar,
        open_time datetime,
        close_time datetime,
        delete_date datetime,
        currency smallint NOT NULL REFERENCES exchange_db.currency(id)
);

CREATE TABLE exchange_db.trader (
      id int PRIMARY KEY,
      first_name varchar,
      last_name varchar,
      timezone smallint NOT NULL REFERENCES exchange_db.time_zone(id),
      country smallint NOT NULL REFERENCES exchange_db.country(id),
      deleted_time datetime
);

CREATE TABLE exchange_db.broker (
      id int PRIMARY KEY,
      legal_entity_identifier varchar,
      timezone smallint NOT NULL REFERENCES exchange_db.time_zone(id),
      country smallint NOT NULL REFERENCES exchange_db.country(id),
      commission double,
      deleted_time datetime,
      actual_address varchar,
      legal_address varchar,
      name varchar
);

CREATE TABLE exchange_db.account (
  number varchar PRIMARY KEY,
  current_funds money,
  trader_code int REFERENCES exchange_db.trader(id),
  broker_code int NOT NULL REFERENCES exchange_db.broker(id),
  type_account type_account,
  type_currency smallint NOT NULL REFERENCES exchange_db.currency(id),
  deleted_time datetime
);

CREATE TABLE exchange_db.depository (
  id bigint PRIMARY KEY,
  quantity int,
  instrument_id smallint NOT NULL REFERENCES  exchange_db.instrument(id),
  account_number int NOT NULL REFERENCES exchange_db.account(number)
);

CREATE TABLE exchange_db.order (
  id bigint PRIMARY KEY,
  place_time datetime,
  cancel_time datetime,
  price money,
  quantity int,
  status order_status,
  side order_side,
  account int NOT NULL REFERENCES  exchange_db.account(number),
  instrument_id int NOT NULL REFERENCES exchange_db.instrument(id),
);

CREATE TABLE exchange_db.trade (
  match_id bigint PRIMARY KEY,
  price money,
  quantity int,
  buy_order_id bigint NOT NULL REFERENCES exchange_db.order(id),
  sell_order_id bigint NOT NULL REFERENCES exchange_db.order(id),
  trade_date datetime
);

CREATE TABLE exchange_db.movement_fund (
  id bigint PRIMARY KEY,
  amount money,
  type type_movement_fund,
  initiator_id int,
  initiator_type initiator_type,
  account_id int NOT NULL REFERENCES exchange_db.account(number)
);


CREATE TABLE exchange_db.currency (
  id smallint,
  currency_name varchar
);

CREATE TABLE exchange_db.country (
  id smallint,
  country_name varchar
);

CREATE TABLE exchange_db.time_zone (
  id smallint,
  utc_time_zone varchar
);




