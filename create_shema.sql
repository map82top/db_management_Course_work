CREATE TYPE type_movement_fund AS ENUM (
  'input',
  'output'
);
-- 
CREATE TABLE currency (
  id smallint PRIMARY KEY,
  currency_name varchar
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

CREATE TABLE country (
  id smallint PRIMARY KEY,
  country_name varchar
);


CREATE TABLE time_zone (
  id smallint PRIMARY KEY,
  utc_time_zone varchar
);

CREATE TABLE market (
        id int PRIMARY KEY,
        name varchar,
        open_time timestamp,
        close_time timestamp,
        delete_date timestamp,
        currency smallint NOT NULL REFERENCES currency(id)
);

CREATE TABLE instrument_template (
        instrument_code varchar(6) PRIMARY KEY,
        short_name varchar(20),
        long_name varchar(256) NOT NULL,
        coupon_rate float,
        coupon_amount float,
        coupon_payment_frequency smallint,
        isin varchar(12) NOT NULL,
        maturity_date timestamp,
        emission_volume float NOT NULL,
        emission_date timestamp NOT NULL,
        delete_date timestamp,
        nominal_price float NOT NULL,
        instrument_type instrument_type NOT NULL,
        currency smallint NOT NULL REFERENCES currency(id)
);

ALTER TABLE instrument_template
    ADD CONSTRAINT bond_required_coupon_rate CHECK(instrument_type = 'bond' AND instrument_type IS NOT NULL OR instrument_type IS NULL),
    ADD CONSTRAINT bond_required_coupon_amount CHECK(instrument_type = 'bond' AND coupon_amount IS NOT NULL OR coupon_amount IS NULL),
    ADD CONSTRAINT bond_required_coupon_payment_frequency CHECK(instrument_type = 'bond' AND coupon_payment_frequency IS NOT NULL OR coupon_payment_frequency IS NULL),
    ADD CONSTRAINT bond_required_maturity_date CHECK(instrument_type = 'bond' AND maturity_date IS NOT NULL OR maturity_date IS NULL),
    ADD CONSTRAINT instrument_code_template CHECK(instrument_code SIMILAR TO '[0-9]{4,6}'),
    ADD CONSTRAINT isin_template CHECK(isin SIMILAR TO '[A-Za-z]{2}[A-Za-z0-9]{9}[0-9]'),
    ADD CONSTRAINT emission_date_less_delete_date CHECK(delete_date IS NOT NULL AND delete_date > emission_date OR delete_date IS NULL),
    ADD CONSTRAINT coupon_amount_more_zero CHECK(coupon_amount > 0),
    ADD CONSTRAINT coupon_rate_zero CHECK(coupon_rate > 0),
    ADD CONSTRAINT coupon_payment_frequency_more_zero CHECK(coupon_payment_frequency > 0);

CREATE TABLE instrument (
        id int PRIMARY KEY,
        delete_date timestamp,
        lot_size int NOT NULL CONSTRAINT instrument_lot_size CHECK(lot_size > 0),
        trading_start_date timestamp NOT NULL CONSTRAINT trading_start_date_less_delete_date CHECK(delete_date IS NOT NULL AND delete_date > trading_start_date OR delete_date IS NULL),
        instrument_template_id varchar(6) NOT NULL REFERENCES  instrument_template(instrument_code),
        market_id smallint NOT NULL REFERENCES market(id)
);

CREATE TABLE trader (
      id int PRIMARY KEY NOT NULL,
      first_name varchar(20) NOT NULL CONSTRAINT only_alphabetic_fn CHECK(first_name ~ '^[A-ZА-Я][а-яa-z-]+$'),
      last_name varchar(25) NOT NULL CONSTRAINT only_alphabetic_ln CHECK(last_name ~ '^[A-ZА-Я][а-яa-z-]+$'),
      timezone smallint NOT NULL REFERENCES time_zone(id),
      country smallint NOT NULL REFERENCES country(id),
      deleted_time timestamp 
);

CREATE TABLE broker (
  id int PRIMARY KEY NOT NULL,
  legal_entity_identifier varchar(20) not null CONSTRAINT lei_regexp CHECK(legal_entity_identifier ~ '^[0-9A-Z]{20}$'),
  timezone smallint NOT NULL REFERENCES time_zone(id),
  country smallint NOT NULL REFERENCES country(id),
  commission numeric(2) NOT NULL CONSTRAINT commission_is_leq_one_and_geq_zero CHECK(commission >= 0::numeric and commission <= 0.1::numeric),
  deleted_time timestamp,
  actual_address varchar(256) NOT NULL CONSTRAINT only_alphabetic_aa CHECK(actual_address ~ '^[A-ZА-Я а-яa-z,.-]+$'),
  legal_address varchar(256) NOT NULL CONSTRAINT only_alphabetic_la CHECK(actual_address ~ '^[A-ZА-Я а-яa-z,.-]+$'),
  name varchar(100) NOT NULL CONSTRAINT only_alphabetic_n CHECK(actual_address ~ '^[A-ZА-Яа-яa-z]+$')
);

CREATE TABLE account (
  number int PRIMARY KEY NOT NULL,
  current_funds money NOT NULL DEFAULT 0 CONSTRAINT if_debet CHECK (type_account = 'debit' and current_funds > 0::money or type_account = 'credit'),
  trader_code int REFERENCES trader(id),
  broker_code int NOT NULL REFERENCES broker(id),
  type_account type_account NOT NULL,
  type_currency smallint NOT NULL REFERENCES currency(id),
  deleted_time timestamp
);

CREATE TABLE depository (
  id bigint PRIMARY KEY,
  quantity int,
  instrument_id smallint NOT NULL REFERENCES  instrument(id),
  account_number int NOT NULL REFERENCES account(number)
);

CREATE TABLE order_ (
  id bigint PRIMARY KEY,
  place_time timestamp,
  cancel_time timestamp,
  price money,
  quantity int,
  status order_status,
  side order_side,
  account int NOT NULL REFERENCES  account(number),
  instrument_id int NOT NULL REFERENCES instrument(id)
);

CREATE TABLE trade (
  match_id bigint PRIMARY KEY NOT NULL,
  price money NOT NULL,
  quantity int NOT NULL,
  buy_order_id bigint NOT NULL REFERENCES order_(id),
  sell_order_id bigint NOT NULL REFERENCES order_(id),
  trade_date timestamp NOT NULL CONSTRAINT date_validation CHECK (trade_date::date <= CURRENT_DATE)
);

CREATE TABLE movement_fund (
  id bigint PRIMARY KEY,
  amount money NOT NULL CONSTRAINT positive_amount CHECK(amount > 0::money),
  type type_movement_fund NOT NULL,
  trader_initiator_id int REFERENCES trader(id) CONSTRAINT if_trader CHECK((initiator_type = 'trader' AND trader_initiator_id is not null) or trader_initiator_id is null),
  broker_initiator_id int REFERENCES broker(id) CONSTRAINT if_broker CHECK((initiator_type = 'broker' AND broker_initiator_id is not null) or broker_initiator_id is null),
  initiator_type initiator_type NOT NULL,
  account_id int NOT NULL REFERENCES account(number)
);











