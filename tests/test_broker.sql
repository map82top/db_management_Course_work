insert into country VALUES(1, 'Russia') ON CONFLICT DO NOTHING;;
insert into time_zone VALUES(1, 'UTC') ON CONFLICT DO NOTHING;;
insert into currency VALUES(1, 'US') ON CONFLICT DO NOTHING;

select create_broker_human('AAAAAAAAAAAAAAAAAAAA','UTC', 'Russia', 0.005, 'Actual Adress', 'Legal Adress', 'A');

insert into market(name, open_time, close_time, currency) VALUES('market', '10:00:00', '18:00:00', 1) ON CONFLICT DO NOTHING;
select add_broker_to_market_human('A', 'market', 'US');
select delete_broker_human('A');
--select delete_broker_from_market_human('A', 'market');

