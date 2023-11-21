# breathing

Audit logging for database.
Logging mechanism using database triggers to store the old and new row states in JSON column types.

## Install

```
gem install breathing
```

## Usage

### Install

Just run the following command.

```
% DATABASE_URL="mysql2://user:pass@host:port/database" breathing install
or
% DATABASE_URL="postgres://user:pass@host:port/database" breathing install
```

- Create table `change_logs`
- Create triggers
    - change_logs_insert_{table_name}
    - change_logs_update_{table_name}
    - change_logs_delete_{table_name}

### Uninstall

Cleanup command.

```
% DATABASE_URL="mysql2://user:pass@host:port/database" breathing uninstall
```

- Drop table `change_logs`
- Drop triggers
    - change_logs_insert_{table_name}
    - change_logs_update_{table_name}
    - change_logs_delete_{table_name}

### Export

```
% DATABASE_URL="mysql2://user:pass@host:port/database" breathing export
```

- Output file `breathing.xlsx`

### out

```
% DATABASE_URL="mysql2://user:pass@host:port/database" breathing out --table users --id 1
```

```
+----------------+------------------------+--------+----+-----+------+----------------------------+----------------------------+
|                                                            users                                                             |
+----------------+------------------------+--------+----+-----+------+----------------------------+----------------------------+
| change_logs.id | change_logs.created_at | action | id | age | name | created_at                 | updated_at                 |
+----------------+------------------------+--------+----+-----+------+----------------------------+----------------------------+
| 1              | 2020-12-18 22:43:32    | INSERT | 10  | 20  | a    | 2020-12-18 13:43:32.316923 | 2020-12-18 13:43:32.316923 |
| 2              | 2020-12-18 22:43:32    | UPDATE | 10  | 21  | a    | 2020-12-18 13:43:32.316923 | 2020-12-18 13:43:32.319706 |
| 3              | 2020-12-18 22:43:32    | DELETE | 10  | 21  | a    | 2020-12-18 13:43:32.316923 | 2020-12-18 13:43:32.319706 |
+----------------+------------------------+--------+----+-----+------+----------------------------+----------------------------+
```

### tail

```
% DATABASE_URL="mysql2://user:pass@host:port/database" breathing tail --table users --id 1
```

## Compatibility

- Ruby 3.0.0+
- MySQL 5.7.0+
- PostgreSQL 8.0+

## Copyright

Copyright (c) 2020 Akira Kusumoto. See MIT-LICENSE file for further details.
