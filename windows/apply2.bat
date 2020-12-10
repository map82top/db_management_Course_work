psql -U postgres -h localhost -f delete_database.sql
psql -U postgres -h localhost -f db_create.sql
psql -U postgres -h localhost -d exchange_db -f ../create_shema.sql
psql -U postgres -h localhost -d exchange_db -f ../helpers_functions.sql
psql -U postgres -h localhost -d exchange_db -f ../broker_functions.sql
psql -U postgres -h localhost -d exchange_db -f ../trader_functions.sql
psql -U postgres -h localhost -d exchange_db -f ../account_functions.sql
psql -U postgres -h localhost -d exchange_db -f ../instrument_template_functions.sql
psql -U postgres -h localhost -d exchange_db -f ../instrument_functions.sql
psql -U postgres -h localhost -d exchange_db -f ../market_functions.sql
echo market_functions
psql -U postgres -h localhost -d exchange_db -f ../order_functions.sql
psql -U postgres -h localhost -d exchange_db -f ../movement_fund_functions.sql
psql -U postgres -h localhost -d exchange_db -f ../trade_functions.sql
psql -U postgres -h localhost -d exchange_db -f ../depository_functions.sql
psql -U postgres -h localhost -d exchange_db -f ../statistic_functions.sql
psql -U postgres -h localhost -d exchange_db -f ../tests/market_analytic.sql
psql -U postgres -h localhost -d exchange_db -f ../demo/market_analytics.sql