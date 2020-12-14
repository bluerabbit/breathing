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

## Compatibility

- Ruby 2.3.0+
- MySQL 5.7.0+
- PostgreSQL 8.0+

## Copyright

Copyright (c) 2020 Akira Kusumoto. See MIT-LICENSE file for further details.
