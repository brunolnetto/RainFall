
'use strict';

const {Client} = require('pg')
const dotenv = require('dotenv');

dotenv.config();

const postgres_credentials =  {
	'user': process.env.POSTGRES_USER,
	'host': process.env.POSTGRES_HOST,
	'database': process.env.POSTGRES_DB_NAME,
	'password': process.env.POSTGRES_KEY,
	'port': process.env.POSTGRES_PORT
};

const client = new Client(postgres_credentials);
client.connect();

module.exports = {
		    client: client,
		    credentials: postgres_credentials
		 };
