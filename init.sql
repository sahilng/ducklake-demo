INSTALL ducklake;
INSTALL postgres;

ATTACH 'ducklake:postgres:dbname=ducklake_catalog_one host=127.0.0.1 user=admin password=admin' AS ducklake_one
    (DATA_PATH 'data/ducklake_one/');
USE ducklake_one;

ATTACH 'ducklake:postgres:dbname=ducklake_catalog_two host=127.0.0.1 user=admin password=admin' AS ducklake_two
    (DATA_PATH 'data/ducklake_two/');

SHOW DATABASES;
