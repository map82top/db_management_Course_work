insert into country VALUES(1, 'Russia');
insert into time_zone VALUES(1, 'UTC');
insert into currency VALUES(1, 'US');

select create_broker_human('AAAAAAAAAAAAAAAAAAAA','UTC', 'Russia', 0.005, 'Actual Adress', 'Legal Adress', 'A');

insert into market(name, open_time, close_time, currency) VALUES('market', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP::date + interval '24 hour', 1);
select add_broker_to_market_human('A', 'market', 'US');
select delete_broker_human('A');
--select delete_broker_from_market_human('A', 'market');

