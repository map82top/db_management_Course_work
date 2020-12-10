SET client_encoding = 'UTF8';

insert into currency values(1, 'RUB'); -- Создается валюта 'RUB'
insert into time_zone values(1, 'UTC+3'); -- Создается временная зона UTC+3
insert into country values(1, 'Russia'); -- Создается страна Россия

\echo '==================== TEST 1 ======================'
\echo 'Creating market with the folowing params:'
\echo 'name: MSE'
\echo 'open time: 08:00:00 UTC+3'
\echo 'close time: 16:00:00 UTC+3'
\echo 'currency: RUB or 1 in terms of forgeing key'
select create_market_human('MSE', '08:00:00 UTC+3', '16:00:00 UTC+3', 'RUB');
\echo 'Result: '
select * from market;
select create_market_human('SPSE', '08:00:00 UTC+3', '16:00:00 UTC+3', 'RUB');


\echo '==================== TEST 2 ======================'
\echo 'Creating broker with the folowing params:'
\echo 'legal entity identifier: AAA22AABBB33333BBBBB'
\echo 'timezone: utc+3 or 1 in terms of ref key'
\echo 'Country: Russia or 1 in terms of rek key'
\echo 'commission: 0.001'
\echo 'Actual Adress: Actual Adress'
\echo 'Legal Adress: Legal Adress'
\echo 'Name: Calentos'
select create_broker_human('AAA22AABBB33333BBBBB', 'UTC+3', 'Russia', 0.001, 'Actual Adress', 'Legal Adress', 'Calentos');
\echo 'Result: '
select * from broker;
select create_broker_human('AAA22AABBB333J3BBBBB', 'UTC+3', 'Russia', 0.0003, '6705 Catherine Neck Apt. 592', '30814 Olson Passage Apt. 825', 'Alpha');
select create_broker_human('AAA22AABBB333JZBBBBB', 'UTC+3', 'Russia', 0.0004, '631 Morales Fords Suite 826', '2439 Dean Well Apt. 271', 'Betta');

\echo '==================== TEST 3 ======================'
\echo 'Creating trader with the folowing params:'
\echo 'First name: Wha'
\echo 'Last name: Sbly'
\echo 'timezone: UTC+3 or 1 in term of ref key'
\echo 'country: Russia or 1 in term of ref key'
\echo 'broker name to create account for trader: Calentos or 1 in terms of ref key'
\echo 'currency: RUB or 1 in term of ref key'
select create_trader_human('Wha','Sbly','UTC+3','Russia','Calentos','RUB');
\echo 'Result:'
\echo 'Trader table:'
select * from trader;
\echo 'Account table: (should be one account with trader_id = 1 and broker_id = 1)'
select * from account;
select create_trader_human('Cbvqqbi','Fevl','UTC+3','Russia','Alpha','RUB');
select create_trader_human('Edkaelgvvya','Vqfzeoimgz','UTC+3','Russia','Betta','RUB');
select create_trader_human('Nfxpi','Mvaq','UTC+3','Russia','Calentos','RUB');
select create_trader_human('Wwyghkgn','Yiwmszl','UTC+3','Russia','Alpha','RUB');
select create_trader_human('Lgn','Rzmrpkzmxm','UTC+3','Russia','Betta','RUB');


\echo '==================== TEST 4 ======================'
\echo 'Addding broker to market:'
\echo 'broker_id: 1'
\echo 'market_id: 1'
\echo 'currency: RUB'
\echo 'There will be created one account for broker on this market. '
\echo 'Its number will be 7 because before that 6 traders were created'
select add_broker_to_market_human('Calentos','MSE','RUB');
\echo 'Result:'
\echo 'Broker on market:'
select * from market_broker;

\echo 'Account:'
select * from account;

select add_broker_to_market_human('Calentos','SPSE','RUB');
select add_broker_to_market_human('Alpha','SPSE','RUB');
select add_broker_to_market_human('Betta','MSE','RUB');
select add_broker_to_market_human('Alpha','MSE','RUB');
select add_broker_to_market_human('Betta','SPSE','RUB');

\echo '==================== TEST 5 ======================'
\echo 'Adding instrument template:'
\echo 'instrument_code: 482801'
\echo 'short_name: Fgz'
\echo 'full_name: Obotljqirijpufbfklmtqfpthojpvsiwvzftgphfcywqfuykbn'
\echo 'coupon_rate: 1.0'
\echo 'coupon_amount: 1.0'
\echo 'coupon_payment_frequency: 1'
\echo 'isin: vxqshdALGGI2'
\echo 'emission_volume: 1000'
\echo 'nominal_price: 2.0'
\echo 'type of instrument: bond'
\echo 'currency: rub or 1 in terms of ref key'
\echo 'emmission date is setted automaticly according to current date'
select add_instrument_template_human('482801','Fgz','Obotljqirijpufbfklmtqfpthojpvsiwvzftgphfcywqfuykbn',1.0,1.0,1::smallint,'vxqshdALGGI2',1000,2.0,'bond','RUB');
\echo 'result:'
select * from instrument_template;
select add_instrument_template_human('1877','Tlvgimmfbwm','Emrvbfrjhhsqessgcjmegkcvushdzvle',1.0,1.0,1::smallint,'UhoVTOMcgDz6',1000,2.0,'bond','RUB');
select add_instrument_template_human('06806','Pzqqm','Qeqxgibrclvruwpcewfnaoiwribeqpw',null,null,null,'LoXm5WoI0t81',1000,2.0,'share','RUB');
select add_instrument_template_human('06807', 'Baddd', 'qtqsafasf', null, null, null, 'LoXm6WoI1t82', 1000, 2.0, 'share', 'RUB');

\echo '==================== TEST 6 ======================'
\echo 'Creating instrument with the following params:'
\echo 'lot_size: 10'
\echo 'instrument_template_code: 482801 or 1 in terms of ref key'
\echo 'market: SPSE or 2 in terms in terms of ref key'
\echo 'trading_start_date: current date + 1 day'
select create_instrument_human(10,'482801','SPSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
\echo 'result: '
select * from instrument;
select create_instrument_human(10,'1877','MSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'06806','SPSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'482801','MSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'1877','SPSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'06806','MSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(10,'06807', 'MSE', (CURRENT_TIMESTAMP + interval '1 day')::date);

\echo '==================== TEST 7 ======================'
\echo 'Creating entry in movement_fund table. Broker deposits his account'
\echo 'amount: 1000000'
\echo 'direction: input'
\echo 'account number: 7'
\echo 'description: initial input'
\echo 'initiator type automaticaly setted in broker'
\echo 'also the current funds on account 7 should be changed to 1,000,000'
select make_broker_movement_fund(1000000::money,'input',7,'initial input');
\echo 'result:'
\echo 'movement fund'
select * from movement_fund;
\echo 'account'
select * from account;
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

\echo '==================== TEST 7 ======================'
\echo 'Initial instrument placement on brokers depositories'
\echo 'Adding depository entry: '
\echo 'price: 10 y.e'
\echo 'quantity: 10000'
\echo 'Account number of broker Calentos (broker_id = 1) on market SPSE(market_id = 2)'
\echo 'from broker_market table'
select * from market_broker;
\echo 'instrument_template_code: 482801 to retrieve instrument on market: 1'
select initial_placement_human(10.0::money,10000,'Calentos','SPSE','482801');
\echo 'result:'
select * from depository;
select initial_placement_human(10.0::money,10000,'Alpha','MSE','1877');
select initial_placement_human(10.0::money,10000,'Betta','SPSE','06806');
select initial_placement_human(10.0::money,10000,'Calentos','MSE','482801');
select initial_placement_human(10.0::money,10000,'Alpha','SPSE','1877');
select initial_placement_human(10.0::money,10000,'Betta','MSE','06806');

\echo '==================== TEST 8 ======================'
\echo 'Changing status of market MSE to open'
\echo 'Before:'
select * from market;
select open_market_human('MSE');
\echo 'After: '
select * from market;
select open_market_human('SPSE');


\echo '==================== TEST 9 ======================'
\echo 'Creating bid order with the following params'
\echo 'account_id: 1'
\echo 'instrument_id: 1'
\echo 'price: 10'
\echo 'quantity: 40'
\echo 'side: bid'
select create_order(1,1,10::money,40, 'bid');
\echo 'Creating offer order with the following params'
\echo 'account_id: 7'
\echo 'instrument_id: 1'
\echo 'price: 10'
\echo 'quantity: 40'
\echo 'side: offer'
\echo 'result:'
select create_order(7,1,10::money,40, 'offer');
select * from order_;
\echo 'Creating trade with previous two orders:'
\echo 'bid_order_id: 1'
\echo 'offer_order_id: 2'
\echo 'quantity: 40'
\echo 'create_trade function affects 4 tables: trade, order_, movement_funds, depository'
\echo 'Before: '
\echo 'Trade'
select * from trade;
\echo 'order_'
select * from order_;
\echo 'movement_funds'
select * from movement_fund;
\echo 'depository'
select * from depository;
select create_trade(1,2,40);
\echo 'After: '
\echo 'Trade'
select * from trade;
\echo 'order_'
select * from order_;
\echo 'movement_funds'
select * from movement_fund;
\echo 'depository'
select * from depository;
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

\echo 'View order statuses for trader with id 2'
select * from get_order_statuses_by_trader_id(2);

\echo '==================== TEST 10 ======================'
\echo 'Close market MSE'
\echo 'When market is closed all orders with status != filled moved to status cancelled'
\echo 'Before'
select * from order_;
select close_market_human('MSE');
\echo 'After'
select * from order_;
select close_market_human('SPSE');

\echo '==================== TEST 11 ======================'
\echo 'Testing output from broker account'
\echo 'amount: 100'
\echo 'type: output'
\echo 'account_number: 7'
\echo 'description: output test'
select make_broker_movement_fund(100::money,'output',7,'output test');
\echo 'result:'
select * from movement_fund ORDER BY id DESC LIMIT 1;
select make_broker_movement_fund(100::money,'output',8,'output test');
select make_broker_movement_fund(100::money,'output',9,'output test');
select make_broker_movement_fund(100::money,'output',10,'output test');
select make_broker_movement_fund(100::money,'output',11,'output test');
select make_broker_movement_fund(100::money,'output',12,'output test');

\echo '==================== TEST 12 ======================'
\echo 'Testing instruments on depository by account number'
\echo 'Account number: 1'
SELECT instrument, quantity from instruments_in_depository_by_account_number(1);

\echo '==================== TEST 12 ======================'
\echo 'movement fund history by account number'
select * from movement_fund_hisory_by_acount_number(1);

\echo '==================== TEST 12 ======================'
\echo 'trade history by date interval'
select * from trade_history_by_date_interval(CURRENT_TIMESTAMP - interval '1 day', CURRENT_TIMESTAMP, 1);
\echo '==================== TEST 12 ======================'
\echo 'commission income by broker id'
select * from commision_income_by_broker_id(1);

\echo '==================== TEST 12 ======================'
\echo 'Trading volume by instrument'
select * from total_trading_volume_by_instrument_id(1);

\echo '==================== TEST 12 ======================'
\echo 'Total income on account'
SELECT * FROM total_income_for_account(1);

\echo '==================== TEST 13 ======================'
\echo 'Analitics. Risk of clients'
SELECT * FROM risk_of_clients(1);

\echo '==================== TEST 14 ======================'
\echo 'Analitics. Instruments_analitic'
SELECT * FROM instruments_analitic(CURRENT_TIMESTAMP - interval '1 day', CURRENT_TIMESTAMP,
15, 5, 2, 0, -5, 15, -15, 5, -5);

\echo '==================== TEST 15 ======================'
\echo 'Analitics. Rating of instruments'
SELECT * FROM rating_of_instruments(30, 15, 5, 2.5);

\echo '==================== TEST 16 ======================'
\echo 'Analitics. Rating of traders'
SELECT * FROM traders_rating(1, 40.0, 20.0);

\echo '==================== TEST 17 ======================'
\echo 'Market analytics'
SELECT * from market_analitic(5, 1, 0.5);
