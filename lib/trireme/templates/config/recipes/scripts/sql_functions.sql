CREATE OR REPLACE FUNCTION create_role_if_not_exists(r_name TEXT, r_pass TEXT)
RETURNS void AS $$
BEGIN
	IF NOT EXISTS (
		SELECT *
		FROM pg_catalog.pg_user
		WHERE usename = $1) THEN
		EXECUTE format('CREATE ROLE %s LOGIN PASSWORD ''%s'' CREATEDB', $1, $2);
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_database_if_not_exists(db_name TEXT, db_owner TEXT)
RETURNS void AS $$
BEGIN
	IF NOT EXISTS (
		SELECT *
		FROM pg_catalog.pg_database
		WHERE datname = $1) THEN
		EXECUTE format('CREATE DATABASE %s OWNER %s', $1, $2);
	END IF;
END;
$$ LANGUAGE plpgsql;