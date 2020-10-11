./build.sh
sleep 1s
docker exec -i study_postgres psql -U postgres -h localhost < create_exchange_db.sql
docker exec -i study_postgres psql -U postgres -h localhost -d exchange_db < ../create_shema.sql