CREATE TYPE "type_movement_fund" AS ENUM (
  'input',
  'output'
);

CREATE TYPE "type_account" AS ENUM (
  'debit',
  'credit'
);

CREATE TYPE "instrument_type" AS ENUM (
  'share',
  'bond'
);

CREATE TYPE "order_side" AS ENUM (
  'bid',
  'offer'
);

CREATE TYPE "order_status" AS ENUM (
  'cancelled',
  'filled',
  'new'
);

CREATE TABLE "trader" (
  "id" SERIAL PRIMARY KEY,
  "first_name" varchar,
  "last_name" varchar,
  "timezone" smallint,
  "country" smallint,
  "deleted_time" datetime
);

CREATE TABLE "broker" (
  "license_number" int PRIMARY KEY,
  "legal_entity_identifier" varchar,
  "timezone" smallint,
  "country" smallint,
  "commission" double,
  "deleted_time" datetime,
  "inn" varchar,
  "kpp" varchar,
  "actual_address" varchar,
  "legal_address" varchar,
  "name" varchar,
  "ks" varchar
);

CREATE TABLE "account" (
  "number" varchar PRIMARY KEY,
  "current_funds" money,
  "trader_code" int,
  "broker_code" int,
  "type_account" type_account,
  "type_currency" smallint,
  "deleted_time" datetime
);

CREATE TABLE "depository" (
  "id" BIGSERIAL PRIMARY KEY,
  "quantity" int,
  "instrument_id" smallint,
  "account_number" int
);

CREATE TABLE "order" (
  "id" BIGSERIAL PRIMARY KEY,
  "place_time" datatime,
  "cancel_time" datatime,
  "price" money,
  "quantity" int,
  "status" order_status,
  "market_id" int,
  "instrument_id" int,
  "order_side" order_side
);

CREATE TABLE "trade" (
  "match_id" BIGSERIAL PRIMARY KEY,
  "quantity" int,
  "buy_order_id" bigint,
  "sell_order_id" bigint
);

CREATE TABLE "movement_fund" (
  "id" BIGSERIAL PRIMARY KEY,
  "amount" money,
  "type" type_movement_fund,
  "initiator_id" int,
  "account_id" int
);

CREATE TABLE "instrument" (
  "id" SERIAL PRIMARY KEY,
  "delete_date" datetime,
  "lot_size" int,
  "trading_start_date" datetime,
  "instrument_template_id" smallint,
  "market_id" smallint
);

CREATE TABLE "instrument_template" (
  "id" SERIAL PRIMARY KEY,
  "short_name" varchar,
  "long_name" varchar,
  "coupon_rate" float,
  "coupon_amount" float,
  "coupon_payment_frequency" smallint,
  "isin" string,
  "maturity_date" datetime,
  "emission_volume" float,
  "emission_date" datetime,
  "delete_date" datetime,
  "nominal_price" float,
  "instrument_type" instrument_type
);

CREATE TABLE "market" (
  "id" SERIAL PRIMARY KEY,
  "name" varchar,
  "open_time" datetime,
  "close_time" datetime,
  "delete_date" datetime
);

CREATE TABLE "currency" (
  "id" smallint,
  "currency_name" varchar
);

CREATE TABLE "country" (
  "id" smallint,
  "country_name" varchar
);

CREATE TABLE "time_zone" (
  "id" smallint,
  "utc_time_zone" varchar
);

ALTER TABLE "trader" ADD FOREIGN KEY ("timezone") REFERENCES "time_zone" ("id");

ALTER TABLE "trader" ADD FOREIGN KEY ("country") REFERENCES "country" ("id");

ALTER TABLE "broker" ADD FOREIGN KEY ("timezone") REFERENCES "time_zone" ("id");

ALTER TABLE "broker" ADD FOREIGN KEY ("country") REFERENCES "country" ("id");

ALTER TABLE "account" ADD FOREIGN KEY ("trader_code") REFERENCES "trader" ("id");

ALTER TABLE "account" ADD FOREIGN KEY ("broker_code") REFERENCES "broker" ("license_number");

ALTER TABLE "account" ADD FOREIGN KEY ("type_currency") REFERENCES "currency" ("id");

ALTER TABLE "depository" ADD FOREIGN KEY ("instrument_id") REFERENCES "instrument" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("market_id") REFERENCES "market" ("id");

ALTER TABLE "order" ADD FOREIGN KEY ("instrument_id") REFERENCES "instrument" ("id");

ALTER TABLE "trade" ADD FOREIGN KEY ("buy_order_id") REFERENCES "order" ("id");

ALTER TABLE "trade" ADD FOREIGN KEY ("sell_order_id") REFERENCES "order" ("id");

ALTER TABLE "movement_fund" ADD FOREIGN KEY ("account_id") REFERENCES "account" ("number");

ALTER TABLE "instrument" ADD FOREIGN KEY ("instrument_template_id") REFERENCES "instrument_template" ("id");

ALTER TABLE "instrument" ADD FOREIGN KEY ("market_id") REFERENCES "market" ("id");
