docker stop study_postgres
docker rm study_postgres
./build.sh
sleep 1s
docker exec -i study_postgres psql -U postgres -h localhost < create_exchange_db.sql
docker exec -i study_postgres psql -U exchange_system -h localhost -d exchange_db < ../create_shema.sql
docker exec -i study_postgres psql -U exchange_system -h localhost -d exchange_db < ../account_functions.sql
docker exec -i study_postgres psql -U exchange_system -h localhost -d exchange_db < ../trader_functions.sql
docker exec -i study_postgres psql -U exchange_system -h localhost -d exchange_db < ../account_functions.sql
docker exec -i study_postgres psql -U exchange_system -h localhost -d exchange_db < ../trader_functions.sql
docker exec -i study_postgres psql -U exchange_system -h localhost -d exchange_db < ../broker_functions.sql
docker exec -i study_postgres psql -U exchange_system -h localhost -d exchange_db < ../instrument_template_functions.sql
docker exec -i study_postgres psql -U exchange_system -h localhost -d exchange_db < ../instrument_functions.sql