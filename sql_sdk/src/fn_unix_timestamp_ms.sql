use catalog identifier(:catalog);
use schema identifier(:schema);

create or replace function unix_timestamp_ms(dt string)
  returns bigint
  deterministic
  comment 'Returns the number of milliseconds since the Unix Epoch. Used with the list_queries function so the results can be reconciled with the Databricks SDK for python. Python and SQL functions don\'t return identical Unix timestamps.'
  language python
  as $$
    from datetime import datetime
    dt_object = datetime.strptime(dt, '%Y-%m-%d %H:%M:%S')
    return int(dt_object.timestamp() * 1000)
  $$;