\echo 'Market volumes: '
select * from market_volumes;
\echo 'Instruments count: '
select * from instruments_per_market;
\echo 'Players on market: '
select * from players_on_market;

\echo 'Query return: '
SELECT * from market_analitic(5, 1, 0.5);