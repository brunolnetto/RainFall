#!/bin/sh

# https://stackoverflow.com/questions/18223665/postgresql-query-from-bash-script-as-database-user-postgres
# Runs su as 'postgres' user & Access psql terminal
sudo -u postgres -H -- psql -U postgres -c "CREATE USER postgres WITH PASSWORD 'postgres' CREATEDB;"
sudo -u postgres -H -- psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE postgres TO postgres;"
sudo -u postgres -H -- psql -U postgres -c "ALTER USER postgres WITH SUPERUSER;"
sudo -u postgres -H -- psql -U postgres -c "CREATE TABLE user_messages (name TEXT, message TEXT);"
sudo -u postgres -H -- psql -U postgres -c "CREATE TABLE users (id UUID PRIMARY KEY, name TEXT NOT NULL);"

