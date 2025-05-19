-- Databricks notebook source
-- MAGIC %md
-- MAGIC ## SQL Scripting Version
-- MAGIC Adds HTTP response checking with [SQL scripting](https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-scripting), which is available in DBSQL 2025.15 and DBR 16.3.
-- MAGIC
-- MAGIC Non-200 responses are logged to a Delta table for review and alerting.

-- COMMAND ----------

-- DBTITLE 1,Define HTTP Connection
/*
Set up a connection to USGS earthquakes feed. This is generally going
to be done separately, but it's included here for simplicity.

https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-syntax-ddl-create-connection
https://earthquake.usgs.gov/earthquakes/feed/v1.0/
*/

create connection if not exists usgs_conn
type HTTP
options (
  host 'https://earthquake.usgs.gov',
  port '443',
  base_path '/earthquakes/feed/v1.0/',
  bearer_token 'na'
);

-- COMMAND ----------

-- DBTITLE 1,Set Catalog and Schema
use catalog identifier(:catalog);
use schema identifier(:schema); 

-- COMMAND ----------

-- DBTITLE 1,Create Error Log Table
create table if not exists earthquakes_log (
  timestamp timestamp,
  job_id string,
  job_run_id string,
  status_code int,
  text string
);

-- COMMAND ----------

-- DBTITLE 1,Get API Response
declare or replace resp struct<status_code int, text string>;

set var resp = (
  select
    http_request(
      conn => 'usgs_conn',
      method => 'GET',
      path => :api_path
    )
);

-- COMMAND ----------

-- DBTITLE 1,Load Data
-- Log non-200 responses to Delta table
-- Script must be in separate notebook cell
begin
  if resp.status_code == 200 then
    create or replace table earthquakes as
    with raw_data as (
      select explode(variant_get(parse_json(resp.text), '$.features')::array<variant>) as col
    )
    select
      col:id::string,
      col:properties.mag::double,
      col:properties.place::string,
      from_unixtime(col:properties.time::bigint/1000) as time,
      col:properties.updated::bigint,
      col:properties.tz::string,
      col:properties.url::string,
      col:properties.detail::string,
      col:properties.felt::string,
      col:properties.cdi::string,
      col:properties.mmi::double,
      col:properties.alert::string,
      col:properties.status::string,
      col:properties.tsunami::string,
      col:properties.sig::bigint,
      col:properties.net::string,
      col:properties.code::string,
      col:properties.ids::string,
      col:properties.sources::string,
      col:properties.types::string,
      col:properties.nst::bigint,
      col:properties.dmin::double,
      col:properties.rms::double,
      col:properties.gap::double,
      col:properties.magType::string,
      col:properties.type::string,
      col:properties.title::string,
      col:geometry.coordinates[0]::double as longitude,
      col:geometry.coordinates[1]::double as latitude,
      col:geometry.coordinates[2]::double as depth
    from raw_data;
  else
    insert into IDENTIFIER(:catalog || '.' || :schema || '.' || 'earthquakes_log')
      values (current_timestamp(), :job_id, :job_run_id, resp.status_code, resp.text);
  end if;
end;