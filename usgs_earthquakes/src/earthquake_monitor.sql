-- Databricks notebook source
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

-- DBTITLE 1,Get Data Using HTTP Connection

/*
Make HTTP request to USGS to get earthquakes in past day.
Feeds - https://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php

https://docs.databricks.com/aws/en/sql/language-manual/functions/http_request
*/

create or replace table earthquakes as
-- Get response and return as variant
with resp as (
select
  parse_json(
    http_request(
      conn => 'usgs_conn',
      method => 'GET',
      path => :api_path
    ).text
  ) as resp_variant
),
-- Convert array of features to rows
response_rows as (
  select
    explode(variant_get(resp_variant, '$.features')::array<variant>) as col
  from resp
)
-- Select desired columns
select
  col:id::string,
  col:properties.mag::double,
  col:properties.place::string,
  from_unixtime(col:properties.time::bigint/1000) as utc_time,
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
from response_rows