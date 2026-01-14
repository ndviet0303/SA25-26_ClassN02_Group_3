-- Create databases if they don't exist
SELECT 'CREATE DATABASE customerdb'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'customerdb')\gexec

SELECT 'CREATE DATABASE paymentdb'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'paymentdb')\gexec

SELECT 'CREATE DATABASE identitydb'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'identitydb')\gexec
