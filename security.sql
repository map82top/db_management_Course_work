GRANT USAGE, SELECT ON ALL SEQUENCEs IN SCHEMA public TO exchange_system;
GRANT USAGE, SELECT ON ALL SEQUENCEs IN SCHEMA public TO broker;
GRANT USAGE, SELECT ON ALL SEQUENCEs IN SCHEMA public TO trader;
GRANT ALL ON currency TO exchange_system;
GRANT ALL ON country TO exchange_system;
GRANT ALL ON time_zone TO exchange_system;
GRANT SELECT ON currency TO broker;
GRANT SELECT ON country TO broker;
GRANT SELECT ON time_zone TO broker;
GRANT SELECT ON currency TO trader;
GRANT SELECT ON country TO trader;
GRANT SELECT ON time_zone TO trader;

-- market
ALTER TABLE market ENABLE ROW LEVEL SECURITY;
CREATE POLICY system_market_select ON market FOR SELECT TO exchange_system  USING (true);
CREATE POLICY system_market_update ON market FOR UPDATE TO exchange_system USING (true) WITH CHECK (true);
CREATE POLICY system_market_insert ON market FOR INSERT TO exchange_system WITH CHECK(deleted_time IS NULL);
CREATE POLICY market_all_view ON market FOR SELECT USING (true);
GRANT SELECT, INSERT, UPDATE ON market TO exchange_system;
GRANT SELECT ON market TO broker;
GRANT SELECT ON market TO trader;

-- instrument_template
ALTER TABLE instrument_template ENABLE ROW LEVEL SECURITY;
CREATE POLICY system_instrument_template_select ON instrument_template FOR SELECT TO exchange_system  USING (true);
CREATE POLICY system_instrument_template_update ON instrument_template FOR UPDATE TO exchange_system  USING (true) WITH CHECK (true);
CREATE POLICY system_instrument_template_insert ON instrument_template FOR INSERT TO exchange_system WITH CHECK(deleted_time IS NULL);
CREATE POLICY instrument_template_all_view ON instrument_template FOR SELECT USING (true);
GRANT SELECT, INSERT, UPDATE ON instrument_template TO exchange_system;
GRANT SELECT ON instrument_template TO trader;
GRANT SELECT ON instrument_template TO broker;

--  instrument
ALTER TABLE instrument ENABLE ROW LEVEL SECURITY;
CREATE POLICY system_instrument_update ON instrument FOR UPDATE TO exchange_system USING (true) WITH CHECK (true);
CREATE POLICY system_instrument_select ON instrument FOR SELECT TO exchange_system USING (true);
CREATE POLICY system_instrument_insert ON instrument FOR INSERT TO exchange_system WITH CHECK(deleted_time IS NULL);
CREATE POLICY instrument_all_view ON instrument FOR SELECT USING (true);
GRANT SELECT, INSERT, UPDATE ON instrument TO exchange_system;
GRANT SELECT ON instrument TO trader;
GRANT SELECT ON instrument TO broker;

-- trader
ALTER TABLE trader ENABLE ROW LEVEL SECURITY;
CREATE POLICY system_trader_select ON trader FOR SELECT TO exchange_system USING (true);
CREATE POLICY system_trader_update ON trader FOR UPDATE TO exchange_system USING (true) WITH CHECK (true);
CREATE POLICY system_trader_insert ON trader FOR INSERT TO exchange_system WITH CHECK(deleted_time IS NULL);
CREATE POLICY trader_all_view ON trader FOR SELECT USING (true);
CREATE POLICY broker_insert_to_trader ON trader FOR INSERT TO broker WITH CHECK(deleted_time IS NULL);
CREATE POLICY broker_update_to_trader ON trader FOR UPDATE TO broker USING (true) WITH CHECK (true);
GRANT SELECT, INSERT, UPDATE ON trader TO exchange_system;
GRANT SELECT ON trader TO trader;
GRANT SELECT, INSERT, UPDATE ON trader TO broker;


-- broker
ALTER TABLE broker ENABLE ROW LEVEL SECURITY;
CREATE POLICY system_broker_select ON broker FOR SELECT TO exchange_system  USING (true);
CREATE POLICY system_broker_update ON broker FOR UPDATE  TO exchange_system USING (true) WITH CHECK (true);
CREATE POLICY system_broker_insert ON broker FOR INSERT TO exchange_system  WITH CHECK(deleted_time IS NULL);
CREATE POLICY broker_all_view ON broker FOR SELECT USING (true);
CREATE POLICY broker_update ON broker FOR UPDATE TO broker USING(true) WITH CHECK (true);
GRANT SELECT, INSERT, UPDATE ON broker TO exchange_system;
GRANT SELECT ON broker TO broker;
GRANT UPDATE (commission, country, timezone, legal_entity_identifier, actual_address, legal_address, name) ON broker TO broker;
GRANT SELECT ON broker TO trader;

-- depository
ALTER TABLE depository ENABLE ROW LEVEL SECURITY;
CREATE POLICY system_depository_all ON depository TO exchange_system USING (true) WITH CHECK (true);
CREATE POLICY depository_all_view ON market FOR SELECT USING (true);
GRANT SELECT, INSERT ON depository TO exchange_system;
GRANT SELECT ON depository TO broker;
GRANT SELECT ON depository TO trader;

-- order
ALTER TABLE order_ ENABLE ROW LEVEL SECURITY;
CREATE POLICY system_order_all ON order_ TO exchange_system USING (true) WITH CHECK (true);
CREATE POLICY order_all_view ON order_ FOR SELECT USING (true);
GRANT SELECT, INSERT, UPDATE ON order_ TO exchange_system;
GRANT SELECT ON order_ TO broker;
GRANT UPDATE (cancel_time, status) ON order_ TO broker;
GRANT SELECT ON order_ TO trader;

-- trade
ALTER TABLE trade ENABLE ROW LEVEL SECURITY;
CREATE POLICY system_trade_all ON trade TO exchange_system USING (true) WITH CHECK (true);
CREATE POLICY trade_all_view ON trade FOR SELECT USING (true);
GRANT SELECT, INSERT ON trade TO exchange_system;
GRANT SELECT ON trade TO broker;
GRANT SELECT ON trade TO trader;

-- movement_fund
ALTER TABLE movement_fund ENABLE ROW LEVEL SECURITY;
CREATE POLICY system_movement_fund_select ON movement_fund FOR SELECT TO exchange_system USING (true);
CREATE POLICY system_movement_fund_insert ON movement_fund FOR INSERT TO exchange_system WITH CHECK (true);
CREATE POLICY movement_fund_all_view ON movement_fund FOR SELECT USING (true);
CREATE POLICY trader_movement_fund_insert ON movement_fund FOR INSERT TO trader WITH CHECK (initiator_type = 'trader');
CREATE POLICY broker_movement_fund_insert ON movement_fund FOR INSERT  TO broker WITH CHECK (initiator_type = 'broker');
GRANT SELECT, INSERT ON movement_fund TO exchange_system;
GRANT SELECT, INSERT ON movement_fund TO broker;
GRANT SELECT, INSERT ON movement_fund TO trader;

-- market_broker
ALTER TABLE market_broker ENABLE ROW LEVEL SECURITY;
CREATE POLICY system_market_broker_all ON market_broker TO exchange_system USING (true) WITH CHECK (true);
CREATE POLICY market_broker_all_view ON market_broker FOR SELECT USING (true);
GRANT SELECT, INSERT, DELETE ON market_broker TO exchange_system;
GRANT SELECT ON market_broker TO broker;
GRANT SELECT ON market_broker TO trader;


-- account
ALTER TABLE account ENABLE ROW LEVEL SECURITY;
CREATE POLICY system_account_select ON account FOR SELECT TO exchange_system USING (true);
CREATE POLICY system_account_update ON account FOR UPDATE  TO exchange_system USING (true) WITH CHECK (true);
CREATE POLICY account_insert ON account FOR INSERT TO exchange_system, broker WITH CHECK(deleted_time IS NULL);
CREATE POLICY account_all_view ON account FOR SELECT USING (true);
GRANT SELECT, INSERT, UPDATE ON account TO exchange_system;
GRANT SELECT, INSERT ON account TO broker;
GRANT UPDATE (current_funds, deleted_time) ON account TO broker;
GRANT SELECT ON account TO trader;
GRANT UPDATE (current_funds) ON account TO trader;

GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO exchange_system;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM trader;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM broker;

GRANT SELECT ON current_prices TO exchange_system, broker, trader;
GRANT SELECT ON float_cash_in_trader_acounts TO exchange_system, broker;
GRANT SELECT ON clean_cash_in_trader_acounts TO exchange_system, broker;
GRANT SELECT ON quantity_instrument_on_accounts TO broker, exchange_system;

GRANT EXECUTE ON FUNCTION create_account TO broker;
GRANT EXECUTE ON FUNCTION delete_account TO broker;
GRANT EXECUTE ON FUNCTION count_instrument_on_account TO broker;
GRANT EXECUTE ON FUNCTION count_instrument_on_account TO trader;
GRANT EXECUTE ON FUNCTION delete_account TO broker;

GRANT EXECUTE ON FUNCTION get_instrument TO broker;
GRANT EXECUTE ON FUNCTION get_instrument TO trader;
GRANT EXECUTE ON FUNCTION get_instrument_template TO broker;
GRANT EXECUTE ON FUNCTION get_instrument_template TO trader;
GRANT EXECUTE ON FUNCTION get_order TO broker;
GRANT EXECUTE ON FUNCTION get_order TO trader;
GRANT EXECUTE ON FUNCTION get_trader TO broker;
GRANT EXECUTE ON FUNCTION get_trader TO trader;
GRANT EXECUTE ON FUNCTION get_account TO broker;
GRANT EXECUTE ON FUNCTION get_account TO trader;
GRANT EXECUTE ON FUNCTION get_market TO broker;
GRANT EXECUTE ON FUNCTION get_market TO trader;
GRANT EXECUTE ON FUNCTION currency_exist TO broker;
GRANT EXECUTE ON FUNCTION currency_exist TO trader;
GRANT EXECUTE ON FUNCTION time_zone_exist TO broker;
GRANT EXECUTE ON FUNCTION time_zone_exist TO trader;
GRANT EXECUTE ON FUNCTION country_exist TO broker;
GRANT EXECUTE ON FUNCTION country_exist TO trader;
GRANT EXECUTE ON FUNCTION iif_sql TO broker;
GRANT EXECUTE ON FUNCTION iif_sql TO trader;

GRANT EXECUTE ON FUNCTION make_trader_movement_fund TO trader;
GRANT EXECUTE ON FUNCTION make_broker_movement_fund TO broker;

GRANT EXECUTE ON FUNCTION cancel_order TO broker;

GRANT EXECUTE ON FUNCTION create_trade TO broker;

GRANT EXECUTE ON FUNCTION instruments_in_depository_by_account_number TO broker;
GRANT EXECUTE ON FUNCTION instruments_in_depository_by_account_number TO trader;

GRANT EXECUTE ON FUNCTION instruments_in_depository_by_trader_id TO trader;
GRANT EXECUTE ON FUNCTION instruments_in_depository_by_trader_id TO broker;

GRANT EXECUTE ON FUNCTION movement_fund_hisory_by_acount_number TO broker;
GRANT EXECUTE ON FUNCTION movement_fund_hisory_by_acount_number TO trader;

GRANT EXECUTE ON FUNCTION trade_history_by_date_interval TO broker;
GRANT EXECUTE ON FUNCTION all_active_orders_on_market TO broker;
GRANT EXECUTE ON FUNCTION all_active_orders_on_market TO trader;

GRANT EXECUTE ON FUNCTION trade_history_by_account_number TO broker;
GRANT EXECUTE ON FUNCTION trade_history_by_account_number TO trader;

GRANT EXECUTE ON FUNCTION commision_income_by_broker_id TO broker;
GRANT EXECUTE ON FUNCTION get_order_statuses_by_trader_id TO broker;
GRANT EXECUTE ON FUNCTION get_order_statuses_by_trader_id TO trader;

GRANT EXECUTE ON FUNCTION total_trading_volume_by_instrument_id TO broker;
GRANT EXECUTE ON FUNCTION total_trading_volume_by_broker_id TO broker;

GRANT EXECUTE ON FUNCTION total_instruments_on_account_clients TO broker;
GRANT EXECUTE ON FUNCTION risk_of_clients TO broker;

GRANT EXECUTE ON FUNCTION total_income_for_account TO trader;
GRANT EXECUTE ON FUNCTION total_income_for_trader TO trader;
GRANT EXECUTE ON FUNCTION total_income_for_trader TO trader;