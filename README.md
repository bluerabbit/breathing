# breathing

Audit logging for database.
Logging mechanism using database triggers to store the old and new row states in JSON column types.

## Install

Put this line in your Gemfile:

```
gem 'breathing'
```

Then bundle:
```
% bundle
```

## Usage

### Install

Just run the following command.

```
% DATABASE_URL="mysql2://user:pass@host:port/database" breathing install
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

### export

```
% DATABASE_URL="mysql2://user:pass@host:port/database" breathing export
```

## Copyright

Copyright (c) 2020 Akira Kusumoto. See MIT-LICENSE file for further details.
