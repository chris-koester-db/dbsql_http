use catalog identifier(:catalog);
use schema identifier(:schema);

create or replace function delete_warehouse(
  id string
)
comment 'Deletes a SQL warehouse. https://docs.databricks.com/api/workspace/warehouses/delete'
return
select
  http_request(
    conn => 'databricks_api',
    method => 'DELETE',
    path => concat('2.0/sql/warehouses/', id)
  ).text as resp;