echo =========================== exchange_system ROLE TESTS ===========================
docker exec -i study_postgres psql -U exchange_system -h localhost -d exchange_db < ../tests/excange_system_role_test.sql

echo =========================== broker ROLE TESTS ===========================
docker exec -i study_postgres psql -U broker -h localhost -d exchange_db < ../tests/broker_role_test.sql


echo =========================== trader ROLE TESTS ===========================
docker exec -i study_postgres psql -U trader -h localhost -d exchange_db < ../tests/trader_role_test.sql