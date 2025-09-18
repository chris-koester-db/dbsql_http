use catalog identifier(:catalog);
use schema identifier(:schema);

create or replace function list_directory_contents(directory_path string)
comment 'Returns the contents of a directory. If there is no directory at the specified path, the API returns a HTTP 404 error. https://docs.databricks.com/api/workspace/files/listdirectorycontents'
return
select
  http_request(
    conn => 'databricks_api',
    method => 'GET',
    path => concat('2.0/fs/directories', directory_path)
  ).text as resp
|> select
     from_json(
       resp,
       'STRUCT<contents: ARRAY<STRUCT<file_size: BIGINT, is_directory: BOOLEAN, last_modified: BIGINT, name: STRING, path: STRING>>>'
     ) as resp;