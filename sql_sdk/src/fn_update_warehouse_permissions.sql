use catalog identifier(:catalog);
use schema identifier(:schema);

create or replace function update_warehouse_permissions(
  warehouse_id string,
  access_control_list string
)
comment 'Updates the permissions on a SQL warehouse. SQL warehouses can inherit permissions from their root object. https://docs.databricks.com/api/workspace/warehouses/updatepermissions'
return
select
  http_request(
    conn => 'databricks_api',
    method => 'PATCH',
    path => concat('2.0/permissions/warehouses/', warehouse_id),
    json => access_control_list
  ).text as resp
|> select
     from_json(
       resp,
       'STRUCT<access_control_list: ARRAY<STRUCT<all_permissions: ARRAY<STRUCT<inherited: BOOLEAN, inherited_from_object: ARRAY<STRING>, permission_level: STRING>>, display_name: STRING, group_name: STRING, service_principal_name: STRING, user_name: STRING>>, object_id: STRING, object_type: STRING>'
     ) as resp;