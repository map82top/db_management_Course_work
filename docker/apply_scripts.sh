docker stop study_postgres
docker rm study_postgres
./build.sh
sleep 1s
echo Start migrations
docker exec -i study_postgres psql -U postgres -h localhost < ../create_exchange_db.sql
echo Performed create_exchange_db
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../create_shema.sql
echo Performed create_shema
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../helpers_functions.sql
echo Performed helpers_functions
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../account_functions.sql
echo Performed account_functions
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../trader_functions.sql
echo Performed trader_functions
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../account_functions.sql
echo Performed account_functions
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../trader_functions.sql
echo Performed trader_functions
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../broker_functions.sql
echo Performed broker_functions
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../instrument_template_functions.sql
echo Performed instrument_template_functions
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../instrument_functions.sql
echo Performed instrument_functions
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../depository_functions.sql
echo Performed depository_functions;
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../movement_fund_functions.sql
echo Performed movement_fund_functions
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../order_functions.sql
echo Performed order_functions
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../market_functions.sql
echo Performed market_functions
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../trade_functions.sql
echo Performed trade_function
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../security.sql
echo Performed security
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../statistic_functions.sql
echo Performed security
docker exec -i study_postgres psql -U exchange_system -h localhost -d exchange_db < ../tests/test_data.sql
