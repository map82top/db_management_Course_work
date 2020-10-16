insert into currency VALUES(1, 'RUB');
select add_instrument_template_human('1111', 'instr', 'instrument', 1.0, 1.0, 1::smallint, 'AAaaaa0aaaa9', 1000::bigint, 2.0, 'bond', 'RUB'); 

insert into market VALUES(1, 'market', CURRENT_TIME - interval '1 hour',CURRENT_TIME - interval '5 minute', null, '1');

insert into instrument VALUES(1, null, 40, CURRENT_TIMESTAMP, '1111', 1);

select remove_instrument_template('1111');