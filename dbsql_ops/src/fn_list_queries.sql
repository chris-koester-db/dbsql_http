use catalog identifier(:catalog);
use schema identifier(:schema);

create or replace function list_queries(
  start_time_ms bigint,
  end_time_ms bigint,
  warehouse_ids array<string>,
  page_token string,
  max_results int default 100,
  include_metrics string default 'true'
)
comment 'List the history of queries through SQL warehouses, and serverless compute. You can filter by user ID, warehouse ID, status, and time range. Most recently started queries are returned first (up to max_results in request). The pagination token returned in response can be used to list subsequent query statuses. include_metrics type is string because of a bug related to boolean arguments. https://docs.databricks.com/api/workspace/queryhistory/list'
return
select
  http_request(
    conn => 'databricks_api',
    method => 'GET',
    path => '2.0/sql/history/queries',
    json => 
      to_json(
        named_struct('filter_by',
          named_struct('query_start_time_range',
            named_struct('start_time_ms', start_time_ms, 'end_time_ms', end_time_ms),
            'warehouse_ids', warehouse_ids
          ),
          'max_results', max_results,
          'page_token', page_token,
          'include_metrics', include_metrics
        )
      )
  ).text as resp
|> select
     from_json(
       resp,
       'struct<has_next_page: boolean, next_page_token: string, res: array<struct<channel_used: struct<dbsql_version: string, name: string>, client_application: string, duration: bigint, endpoint_id: string, error_message: string, executed_as_user_id: bigint, executed_as_user_name: string, execution_end_time_ms: bigint, is_final: boolean, lookup_key: string, metrics: struct<compilation_time_ms: bigint, execution_time_ms: bigint, network_sent_bytes: bigint, overloading_queue_start_timestamp: bigint, photon_total_time_ms: bigint, provisioning_queue_start_timestamp: bigint, pruned_bytes: bigint, pruned_files_count: bigint, query_compilation_start_timestamp: bigint, read_bytes: bigint, read_cache_bytes: bigint, read_files_count: bigint, read_partitions_count: bigint, read_remote_bytes: bigint, result_fetch_time_ms: bigint, result_from_cache: boolean, rows_produced_count: bigint, rows_read_count: bigint, spill_to_disk_bytes: bigint, task_total_time_ms: bigint, total_time_ms: bigint, write_remote_bytes: bigint>, plans_state: string, query_end_time_ms: bigint, query_id: string, query_source: struct<alert_id: string, dashboard_id: string, genie_space_id: string, job_info: struct<job_id: string, job_run_id: string, job_task_run_id: string>, legacy_dashboard_id: string, notebook_id: string, sql_query_id: string>, query_start_time_ms: bigint, query_text: string, rows_produced: bigint, spark_ui_url: string, statement_type: string, status: string, user_id: bigint, user_name: string, warehouse_id: string>>>'
     );