\echo '==================== TEST 1 ======================'
\echo 'Create ORDER WITH incorrect INSTRUMENT'
\echo 'Instrument id 15'
SELECT * FROM get_instrument(15);
\echo 'Side: OFFER'
\echo 'Price: 5.56'
\echo 'Quantity: 20'
\echo 'Leaves quantity: 20'
\echo 'Account number: 8'
SELECT * FROM get_account(8);

\echo 'Error'
INSERT INTO order_ (place_time, price, quantity, leaves_qty, side, account, instrument_id)
VALUES(CURRENT_TIMESTAMP, 5.56, 20, 20, 'offer', 8, 15);

SELECT open_market(1);

\echo '==================== TEST 2 ======================'
\echo 'Create ORDER WITH cancel time'
\echo 'Instrument id 6'
SELECT * FROM get_instrument(6);
\echo 'Side: BID'
\echo 'Price: 5.56'
\echo 'Quantity: 20'
\echo 'Leaves quantity: 20'
\echo 'Account number: 8'
SELECT * FROM get_account(8);

\echo 'Error'
INSERT INTO order_ (place_time, cancel_time, price, quantity, leaves_qty, side, account, instrument_id)
VALUES(CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 5.56, 20, 20, 'bid', 8, 6);


\echo '==================== TEST 3 ======================'
\echo 'Create ORDER WITH quantity instruments more then has in depositary account'
\echo 'Instrument id 6'
SELECT * FROM get_instrument(6);
\echo 'Side: OFFER'
\echo 'Price: 5.56'
\echo 'Quantity: 10000'
\echo 'Leaves quantity: 10000'
\echo 'Account number: 8'
SELECT * FROM get_account(8);

\echo 'Error'
INSERT INTO order_ (place_time, price, quantity, leaves_qty, side, account, instrument_id)
VALUES(CURRENT_TIMESTAMP, 5.56, 10000, 10000, 'offer', 8, 6);

SELECT close_market(1);

\echo '==================== TEST 4 ======================'
\echo 'Create correct ORDER but MARKET is closed'
\echo 'Instrument id 6'
SELECT * FROM get_instrument(6);
\echo 'Side: BID'
\echo 'Price: 5.56'
\echo 'Quantity: 20'
\echo 'Leaves quantity: 20'
\echo 'Account number: 8'
SELECT * FROM get_account(8);

\echo 'Error'
INSERT INTO order_ (place_time, price, quantity, leaves_qty, side, account, instrument_id)
VALUES(CURRENT_TIMESTAMP, 5.56, 20, 20, 'bid', 8, 6);

\echo '==================== TEST 5 ======================'
\echo 'Open market'
SELECT open_market(1);

INSERT INTO order_ (place_time, price, quantity, leaves_qty, side, account, instrument_id)
VALUES(CURRENT_TIMESTAMP, 5.56, 20, 20, 'bid', 8, 6);

SELECT * FROM order_ o ORDER BY id DESC LIMIT 1;

