psql -U postgres -h localhost -f delete_database.sql
psql -U postgres -h localhost -f db_create.sql
psql -U postgres -h localhost -d exchange_db -f ../create_shema.sql
psql -U postgres -h localhost -d exchange_db -f ../broker_functions.sql
psql -U postgres -h localhost -d exchange_db -f ../trader_functions.sql
psql -U postgres -h localhost -d exchange_db -f ../account_functions.sql
psql -U postgres -h localhost -d exchange_db -f test_broker.sql