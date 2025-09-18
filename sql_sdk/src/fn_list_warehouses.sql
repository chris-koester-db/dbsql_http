use catalog identifier(:catalog);
use schema identifier(:schema);

create or replace function list_warehouses(
  run_as_user_id int default null
)
comment 'Lists all SQL warehouses that a user has manager permissions on. https://docs.databricks.com/api/workspace/warehouses/list'
return
select
  http_request(
    conn => 'databricks_api',
    method => 'GET',
    path => '2.0/sql/warehouses',
    json => 
      to_json(
        named_struct(
          'run_as_user_id', run_as_user_id
        )
      )
  ).text as resp
|> select
     from_json(
       resp,
       'STRUCT<warehouses: ARRAY<STRUCT<auto_stop_mins: STRING, channel: STRUCT<dbsql_version: STRING, name: STRING>, cluster_size: STRING, creator_name: STRING, enable_photon: BOOLEAN, enable_serverless_compute: BOOLEAN, health: STRUCT<details: STRING, failure_reason: STRUCT<code: STRING, parameters: STRUCT<property1: STRING, property2: STRING>, type: STRING>, message: STRING, status: STRING, summary: STRING>, id: STRING, instance_profile_arn: STRING, jdbc_url: STRING, max_num_clusters: BIGINT, min_num_clusters: STRING, name: STRING, num_active_sessions: BIGINT, num_clusters: BIGINT, odbc_params: STRUCT<hostname: STRING, path: STRING, port: BIGINT, protocol: STRING>, spot_instance_policy: STRING, state: STRING, tags: STRUCT<custom_tags: ARRAY<STRUCT<key: STRING, value: STRING>>>, warehouse_type: STRING>>>'
     ) as resp;