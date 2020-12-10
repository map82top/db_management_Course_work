insert into currency values(1, 'RUB'); -- Создается валюта 'RUB'
insert into time_zone values(1, 'UTC+3'); -- Создается временная зона UTC+3
insert into country values(1, 'Russia'); -- Создается страна Россия


-- Создается 2 маркета: MSE и SPSE
select create_market_human('MSE', '08:00:00 UTC+3', '16:00:00 UTC', 'RUB'); 
select create_market_human('SPSE', '06:00:00 UTC+3', '18:00:00 UTC+3', 'RUB');
\echo 'Провера создания маркетов:'
Select * from market;

-- Создается 3 брокера: Calentos, Alpha, Betta

select create_broker_human('AAA22AABBB33333BBBBB', 'UTC+3', 'Russia', 0.001, 'Actual Adress', 'Legal Adress', 'Calentos');
select create_broker_human('AAA22AABBB333J3BBBBB', 'UTC+3', 'Russia', 0.0003, '6705 Catherine Neck Apt. 592', '30814 Olson Passage Apt. 825', 'Alpha');
select create_broker_human('AAA22AABBB333JZBBBBB', 'UTC+3', 'Russia', 0.0004, '631 Morales Fords Suite 826', '2439 Dean Well Apt. 271', 'Betta');

\echo 'Проверка создания брокеров (Должно быть 3):'
select * from broker;


-- Когда создается трейдер сразу создается и счет для него
-- Создается 2 трейдера привязанных к брокеру Calentos: Wha, Nfxpi
select create_trader_human('Wha','Sbly','UTC+3','Russia','Calentos','RUB');
select create_trader_human('Nfxpi','Mvaq','UTC+3','Russia','Calentos','RUB');

-- Создается 2 трейдера привязанных к брокеру Alpha: Cbvqqbi, Wwyghkgn
select create_trader_human('Cbvqqbi','Fevl','UTC+3','Russia','Alpha','RUB');
select create_trader_human('Wwyghkgn','Yiwmszl','UTC+3','Russia','Alpha','RUB');

-- Создается 2 трейдера привязанных к брокеру Betta: Lgn, Edkaelgvvya
select create_trader_human('Edkaelgvvya','Vqfzeoimgz','UTC+3','Russia','Betta','RUB');
select create_trader_human('Lgn','Rzmrpkzmxm','UTC+3','Russia','Betta','RUB');

\echo 'Проверка создания трейдеров:'
select * from trader;

\echo 'Проверка создания счетов для трейдеров:'
select * from account;


-- Создаются счета для всех брокеров и все брокеры "добавляются" на маркет
select add_broker_to_market_human('Calentos','MSE','RUB');
select add_broker_to_market_human('Calentos','SPSE','RUB');
select add_broker_to_market_human('Alpha','SPSE','RUB');
select add_broker_to_market_human('Betta','MSE','RUB');
select add_broker_to_market_human('Alpha','MSE','RUB');
select add_broker_to_market_human('Betta','SPSE','RUB');

\echo 'Проверка создания счетов для брокеров: '
select * from account where trader_code is null;

-- Создаются шаблоны инструментов: 482801, 1877, 06806, 06807
select add_instrument_template_human('482801','Fgz','Obotljqirijpufbfklmtqfpthojpvsiwvzftgphfcywqfuykbn',1.0,1.0,1::smallint,'vxqshdALGGI2',1000,2.0,'bond','RUB');
select add_instrument_template_human('1877','Tlvgimmfbwm','Emrvbfrjhhsqessgcjmegkcvushdzvle',1.0,1.0,1::smallint,'UhoVTOMcgDz6',1000,2.0,'bond','RUB');
select add_instrument_template_human('06806','Pzqqm','Qeqxgibrclvruwpcewfnaoiwribeqpw',null,null,null,'LoXm5WoI0t81',1000,2.0,'share','RUB');
select add_instrument_template_human('06807', 'Baddd', 'qtqsafasf', null, null, null, 'LoXm6WoI1t82', 1000, 2.0, 'share', 'RUB');

\echo 'Проверка создания шаблонов инструментов: '
select * from instrument_template;

-- На основе шаблонов инструметов создаются экземпляры инструментов для торговли на созданных маркетах, c размером лота 10:
select create_instrument_human(10,'482801','SPSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'1877','MSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'06806','SPSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'482801','MSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'1877','SPSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'06806','MSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'06807', 'MSE', (CURRENT_TIMESTAMP + interval '1 day')::date);

\echo 'Проверка создания инструментов: '
select * from instrument;

-- Счета брокеров и трейдеров пополняются у.е для возможности торговать инструменты:
select make_broker_movement_fund(1000000::money,'input',7,'initial input');
select make_broker_movement_fund(1000000::money,'input',8,'initial input');
select make_broker_movement_fund(1000000::money,'input',9,'initial input');
select make_broker_movement_fund(1000000::money,'input',10,'initial input');
select make_broker_movement_fund(1000000::money,'input',11,'initial input');
select make_broker_movement_fund(1000000::money,'input',12,'initial input');
select make_trader_movement_fund(1000000::money,'input',1,'initial input');
select make_trader_movement_fund(1000000::money,'input',2,'initial input');
select make_trader_movement_fund(1000000::money,'input',3,'initial input');
select make_trader_movement_fund(100000::money,'input',4,'initial input');
select make_trader_movement_fund(1000000::money,'input',5,'initial input');
select make_trader_movement_fund(1000000::money,'input',6,'initial input');

\echo 'Проверка появления initial input'
select * from movement_fund;

-- На депозитарии брокеров покупаются инструменты, чтобы они могли предоставить их своим трейдерам для покупки
select initial_placement_human(10.0::money,10000,'Calentos','SPSE','482801');
select initial_placement_human(10.0::money,10000,'Alpha','MSE','1877');
select initial_placement_human(10.0::money,10000,'Betta','SPSE','06806');
select initial_placement_human(10.0::money,10000,'Calentos','MSE','482801');
select initial_placement_human(10.0::money,10000,'Alpha','SPSE','1877');
select initial_placement_human(10.0::money,10000,'Betta','MSE','06806');

\echo 'Проверка размещения инструментов на депозитариях брокеров: '
select * from depository;

\echo 'проверка движения средств: '
select * from movement_fund;

-- Открытие маркетов
select open_market_human('MSE');
select open_market_human('SPSE');

-- Покупка трейдером Wha инструментов 482801 у брокера Calentos в количестве 40 штук
select create_order(1,1,10::money,40, 'bid');
select create_order(7,1,10::money,40, 'offer');
select create_trade(1,2,40);

-- Продажа трейдером Wha 40 инструментов 482801 трейдеру Nfxpi в 3 трейда
select create_order(1,1,11::money, 40, 'offer');
select create_order(4,1,11::money, 20, 'bid');
select create_order(4,1,11::money, 20, 'bid');
select create_trade(4,3,20);
select create_trade(5,3,10);
select create_trade(5,3,10);

-- Покупка трейдером 
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
select create_order(1,4,2000::money, 40, 'offer');
select create_order(4,4,2000::money, 20, 'bid');
select create_order(4,4,2000::money, 20, 'bid');
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

select create_order(4,4,10::money, 40, 'offer');
select create_order(1,4,10::money, 40, 'bid');
select create_trade(35,36,40);

\echo 'Проверка создания заявок в количестве 34: '
select * from order_;

\echo 'Проверка создания сделок в количистве 26: '
select * from trade;

\echo 'Проверка движения средств после сделок 140 + 18(было до этого): '
select * from movement_fund;

\echo 'Проверка прихода и убыли в депозитариях: '
select * from depository;

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

select * from float_cash_in_trader_acounts;
select * from clean_cash_in_trader_acounts;
select * from current_prices;

select * from depository d where account_number = 4; 

SELECT * FROM risk_of_clients(2);
