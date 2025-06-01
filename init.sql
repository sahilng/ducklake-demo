INSTALL ducklake;
INSTALL postgres;

ATTACH 'ducklake:postgres:dbname=ducklake_catalog host=127.0.0.1 user=admin password=admin' AS my_ducklake
    (DATA_PATH 'data_files/');
USE my_ducklake;

ATTACH 'ducklake:postgres:dbname=ducklake_catalog_two host=127.0.0.1 user=admin password=admin' AS my_ducklake_two
    (DATA_PATH 'data_files_two/');
USE my_ducklake_two;
