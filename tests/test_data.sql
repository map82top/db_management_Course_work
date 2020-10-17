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

select create_instrument_human(73,'482801','SPSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(21,'1877','MSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(27,'06806','SPSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(22,'482801','MSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(67,'1877','SPSE',(CURRENT_TIMESTAMP + interval '1 day')::date);
select create_instrument_human(15,'06806','MSE',(CURRENT_TIMESTAMP + interval '1 day')::date);


