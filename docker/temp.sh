docker exec -i study_postgres psql -U exchange_system -h localhost -d exchange_db < ../depository_functions.sql
echo Performed depository_functions;