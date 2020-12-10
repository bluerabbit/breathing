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
    - breathing_insert_{table_name}
    - breathing_update_{table_name}
    - breathing_delete_{table_name}

### Uninstall

Cleanup command.

```
% DATABASE_URL="mysql2://user:pass@host:port/database" breathing uninstall
```

- Drop table `change_logs`
- Drop triggers
    - breathing_insert_{table_name}
    - breathing_update_{table_name}
    - breathing_delete_{table_name}

## Copyright

Copyright (c) 2020 Akira Kusumoto. See MIT-LICENSE file for further details.
