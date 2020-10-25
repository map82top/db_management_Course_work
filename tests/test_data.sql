insert into currency values(1, 'RUB');
insert into time_zone values(1, 'UTC+3');
insert into country values(1, 'Russia');

select create_market_human('MSE', '08:00:00 UTC+3', '16:00:00 UTC', 'RUB');
select create_market_human('SPSE', '06:00:00 UTC+3', '18:00:00 UTC+3', 'RUB');

select create_broker_human('AAA22AABBB33333BBBBB', 'UTC+3', 'Russia', 0.001, 'Actual Adress', 'Legal Adress', 'Calentos');
select create_broker_human('AAA22AABBB333J3BBBBB', 'UTC+3', 'Russia', 0.0003, '6705 Catherine Neck Apt. 592', '30814 Olson Passage Apt. 825', 'Alpha');
select create_broker_human('AAA22AABBB333JZBBBBB', 'UTC+3', 'Russia', 0.0004, '631 Morales Fords Suite 826', '2439 Dean Well Apt. 271', 'Betta');

select create_trader_human('Wha','Sbly','UTC+3','Russia','Calentos','RUB');
select create_trader_human('Cbvqqbi','Fevl','UTC+3','Russia','Alpha','RUB');
select create_trader_human('Edkaelgvvya','Vqfzeoimgz','UTC+3','Russia','Betta','RUB');
select create_trader_human('Nfxpi','Mvaq','UTC+3','Russia','Calentos','RUB');
select create_trader_human('Wwyghkgn','Yiwmszl','UTC+3','Russia','Alpha','RUB');
select create_trader_human('Lgn','Rzmrpkzmxm','UTC+3','Russia','Betta','RUB');

select add_broker_to_market_human('Calentos','MSE','RUB');
select add_broker_to_market_human('Alpha','SPSE','RUB');
select add_broker_to_market_human('Betta','MSE','RUB');
select add_broker_to_market_human('Calentos','SPSE','RUB');
select add_broker_to_market_human('Alpha','MSE','RUB');
select add_broker_to_market_human('Betta','SPSE','RUB');

select add_instrument_template_human('482801','Fgz','Obotljqirijpufbfklmtqfpthojpvsiwvzftgphfcywqfuykbn',1.0,1.0,1::smallint,'vxqshdALGGI2',1000,2.0,'bond','RUB');
select add_instrument_template_human('1877','Tlvgimmfbwm','Emrvbfrjhhsqessgcjmegkcvushdzvle',1.0,1.0,1::smallint,'UhoVTOMcgDz6',1000,2.0,'bond','RUB');
select add_instrument_template_human('06806','Pzqqm','Qeqxgibrclvruwpcewfnaoiwribeqpw',null,null,null,'LoXm5WoI0t81',1000,2.0,'share','RUB');

select create_instrument_human(10,'482801','SPSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'1877','MSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'06806','SPSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'482801','MSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'1877','SPSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'06806','MSE',(CURRENT_TIMESTAMP + interval '1 day')::date);

select make_broker_movement_fund(1000000::money,'input',7,'initial input');
select make_broker_movement_fund(1000000::money,'input',8,'initial input');
select make_broker_movement_fund(1000000::money,'input',9,'initial input');
select make_broker_movement_fund(1000000::money,'input',10,'initial input');
select make_broker_movement_fund(1000000::money,'input',11,'initial input');
select make_broker_movement_fund(1000000::money,'input',12,'initial input');
select make_trader_movement_fund(100000::money,'input',1,'initial input');
select make_trader_movement_fund(100000::money,'input',2,'initial input');
select make_trader_movement_fund(100000::money,'input',3,'initial input');
select make_trader_movement_fund(100000::money,'input',4,'initial input');
select make_trader_movement_fund(100000::money,'input',5,'initial input');
select make_trader_movement_fund(100000::money,'input',6,'initial input');

select initial_placement_human(10.0::money,10000,'Calentos','SPSE','482801');
select initial_placement_human(10.0::money,10000,'Alpha','MSE','1877');
select initial_placement_human(10.0::money,10000,'Betta','SPSE','06806');
select initial_placement_human(10.0::money,10000,'Calentos','MSE','482801');
select initial_placement_human(10.0::money,10000,'Alpha','SPSE','1877');
select initial_placement_human(10.0::money,10000,'Betta','MSE','06806');

select open_market_human('MSE');
select open_market_human('SPSE');


select create_order(1,1,10::money,40, 'bid');
select create_order(7,1,10::money,40, 'offer');
select create_trade(1,2,40);
select create_order(1,1,11::money, 40, 'offer');
select create_order(4,1,11::money, 20, 'bid');
select create_order(4,1,11::money, 20, 'bid');
select create_trade(4,3,20);
select create_trade(5,3,10);
select create_trade(5,3,10);

select create_order(2,2,10::money,40, 'bid');
select create_order(8,2,10::money,40, 'offer');
select create_trade(6,7,40);
select create_order(2,2,11::money, 40, 'offer');
select create_order(5,2,11::money, 20, 'bid');
select create_order(5,2,11::money, 20, 'bid');
select create_trade(9,8,20);
select create_trade(10,8,10);
select create_trade(10,8,10);

select create_order(3,3,10::money,40, 'bid');
select create_order(9,3,10::money,40, 'offer');
select create_trade(11,12,40);
select create_order(3,3,11::money, 40, 'offer');
select create_order(6,3,11::money, 20, 'bid');
select create_order(6,3,11::money, 20, 'bid');
select create_trade(14,13,20);
select create_trade(15,13,10);
select create_trade(15,13,10);

select create_order(1,4,10::money,40, 'bid');
select create_order(10,4,10::money,40, 'offer');
select create_trade(16,17,40);
select create_order(1,4,11::money, 40, 'offer');
select create_order(4,4,11::money, 20, 'bid');
select create_order(4,4,11::money, 20, 'bid');
select create_trade(19,18,20);
select create_trade(20,18,10);
select create_trade(20,18,10);

select create_order(2,5,10::money,40, 'bid');
select create_order(11,5,10::money,40, 'offer');
select create_trade(21,22,40);
select create_order(2,5,11::money, 40, 'offer');
select create_order(5,5,11::money, 20, 'bid');
select create_order(5,5,11::money, 20, 'bid');
select create_trade(24,23,20);
select create_trade(25,23,10);
select create_trade(25,23,10);

select create_order(3,6,10::money,50, 'bid');
select create_order(12,6,10::money,50, 'offer');
select create_trade(26,27,50);
select create_order(3,6,11::money, 40, 'offer');
select create_order(6,6,11::money, 20, 'bid');
select create_order(6,6,11::money, 20, 'bid');
select create_trade(29,28,10);
select create_trade(30,28,10);
select create_trade(30,28,10);

select create_order(1,1,10::money,40, 'bid');
select create_order(7,1,10::money,40, 'offer');
select create_trade(31, 32, 40);
select create_order(1,2,10::money,40, 'bid');
select create_order(8,2,10::money,40, 'offer');
select create_trade(33, 34, 40);

select * from all_active_orders_on_market(6);
select * from get_order_statuses_by_trader_id(2);

select close_market_human('MSE');
select close_market_human('SPSE');

select make_broker_movement_fund(100::money,'output',7,'output test');
select make_broker_movement_fund(100::money,'output',8,'output test');
select make_broker_movement_fund(100::money,'output',9,'output test');
select make_broker_movement_fund(100::money,'output',10,'output test');
select make_broker_movement_fund(100::money,'output',11,'output test');
select make_broker_movement_fund(100::money,'output',12,'output test');

SELECT instrument, quantity from instruments_in_depository_by_account_number(1);
SELECT instrument, quantity from instruments_in_depository_by_trader_id(1);
select * from movement_fund_hisory_by_acount_number(1);
select * from trade_history_by_date_interval(CURRENT_TIMESTAMP - interval '1 day', CURRENT_TIMESTAMP, 1);
select * from trade_history_by_account_number(2);
select * from commision_income_by_broker_id(1);

select * from total_trading_volume_by_instrument_id(1);
select * from total_trading_volume_by_broker_id(1, CURRENT_TIMESTAMP - interval '1 day', CURRENT_TIMESTAMP);