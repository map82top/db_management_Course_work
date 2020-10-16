INSERT INTO time_zone(utc_time_zone) VALUES('YAKT') ON CONFLICT DO NOTHING;
INSERT INTO country(country_name) VALUES('Russia') ON CONFLICT DO NOTHING;
INSERT INTO currency(currency_name) VALUES('RUB') ON CONFLICT DO NOTHING;
INSERT INTO broker (timezone, country, commission, actual_address, legal_address, name) VALUES(1, 1, 0.005, 'Actual address', 'Legal address', 'Firstbroker') ON CONFLICT DO NOTHING;

SELECT create_trader_human('Ilya', 'Burov', 'YAKT', 'Russia', 'Firstbroker', 'RUB');

SELECT create_account_human('Ilya', 'Burov', 'Firstbroker', 'credit', 'RUB');

SELECT delete_trader_human('Ilya', 'Burov');