use catalog identifier(:catalog);
use schema identifier(:schema);

create or replace function get_warehouse_permission_levels(
  warehouse_id string
)
comment 'Gets the permission levels that a user can have on an object. https://docs.databricks.com/api/workspace/warehouses/getpermissionlevels'
return
select
  http_request(
    conn => 'databricks_api',
    method => 'GET',
    path => concat('2.0/permissions/warehouses/', warehouse_id, '/permissionLevels')
  ).text as resp
|> select
     from_json(
       resp,
       'STRUCT<permission_levels: ARRAY<STRUCT<description: STRING, permission_level: STRING>>>'
     ) as resp;