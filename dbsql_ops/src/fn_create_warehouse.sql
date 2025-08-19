use catalog identifier(:catalog);
use schema identifier(:schema);

create or replace function create_warehouse(
  auto_stop_mins int default null,
  channel_name string default 'CHANNEL_NAME_CURRENT',
  cluster_size string default null,
  creator_name string default null,
  enable_serverless_compute string default null,
  instance_profile_arn string default null,
  max_num_clusters int default null,
  min_num_clusters int default null,
  name string default null,
  spot_instance_policy string default null,
  custom_tags array<struct<key:string,value:string>> default null,
  warehouse_type string default null
)
comment 'Creates a new SQL warehouse. https://docs.databricks.com/api/workspace/warehouses/create'
return
select
  http_request(
    conn => 'databricks_api',
    method => 'POST',
    path => '2.0/sql/warehouses',
    json => 
      to_json(
        named_struct(
          'auto_stop_mins', auto_stop_mins,
          'channel', named_struct(
            'dbsql_version', null,
            'name', channel_name
          ),
          'cluster_size', cluster_size,
          'creator_name', creator_name,
          'enable_photon', true,
          'enable_serverless_compute', enable_serverless_compute,
          'instance_profile_arn', instance_profile_arn,
          'max_num_clusters', max_num_clusters,
          'min_num_clusters', min_num_clusters,
          'name', name,
          'spot_instance_policy', spot_instance_policy,
          'tags', named_struct(
            'custom_tags', custom_tags
          ),
          'warehouse_type', warehouse_type
        )
      )
  ).text as resp
|> select
     from_json(
       resp,
       'STRUCT<id: STRING>'
     ) as resp;