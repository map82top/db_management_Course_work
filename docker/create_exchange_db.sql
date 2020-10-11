CREATE ROLE exchange_system LOGIN ENCRYPTED PASSWORD 'Testpwd1' VALID UNTIL 'infinity';

CREATE DATABASE exchange_db
	WITH OWNER = exchange_system
	ENCODING = 'UTF8' 
	TABLESPACE = pg_default
	LC_COLLATE = 'C'
	LC_CTYPE =  'C'
	CONNECTION LIMIT = -1
	TEMPLATE template0;
