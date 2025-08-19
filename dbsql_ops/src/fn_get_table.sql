use catalog identifier(:catalog);
use schema identifier(:schema);

create or replace function get_table(
  catalog_name string,
  schema_name string,
  table_name string
)
comment 'Gets a table from the metastore for a specific catalog and schema. https://docs.databricks.com/api/workspace/tables/get'
return
select
  http_request(
    conn => 'databricks_api',
    method => 'GET',
    path => concat('2.1/unity-catalog/tables/', catalog_name, '.', schema_name, '.', table_name)
  ).text as resp
|> select
     from_json(
       resp,
       'STRUCT<access_point: STRING, browse_only: BOOLEAN, catalog_name: STRING, columns: ARRAY<STRUCT<comment: STRING, mask: STRUCT<function_name: STRING, using_column_names: ARRAY<STRING>>, name: STRING, nullable: BOOLEAN, partition_index: BIGINT, position: BIGINT, type_interval_type: STRING, type_json: STRING, type_name: STRING, type_precision: BIGINT, type_scale: BIGINT, type_text: STRING>>, comment: STRING, created_at: BIGINT, created_by: STRING, data_access_configuration_id: STRING, data_source_format: STRING, deleted_at: BIGINT, delta_runtime_properties_kvpairs: STRUCT<delta_runtime_properties: MAP<STRING, STRING>>, effective_predictive_optimization_flag: STRUCT<inherited_from_name: STRING, inherited_from_type: STRING, value: STRING>, enable_predictive_optimization: STRING, full_name: STRING, metastore_id: STRING, name: STRING, owner: STRING, pipeline_id: STRING, properties: MAP<STRING, STRING>, row_filter: STRUCT<function_name: STRING, input_column_names: ARRAY<STRING>>, schema_name: STRING, sql_path: STRING, storage_credential_name: STRING, storage_location: STRING, table_constraints: ARRAY<STRUCT<foreign_key_constraint: STRUCT<child_columns: ARRAY<STRING>, name: STRING, parent_columns: ARRAY<STRING>, parent_table: STRING>, named_table_constraint: STRUCT<name: STRING>, primary_key_constraint: STRUCT<child_columns: ARRAY<STRING>, name: STRING>>>, table_id: STRING, table_type: STRING, updated_at: BIGINT, updated_by: STRING, view_definition: STRING, view_dependencies: STRUCT<dependencies: ARRAY<STRUCT<function: STRUCT<function_full_name: STRING>, table: STRUCT<table_full_name: STRING>>>>>'
     ) as resp;