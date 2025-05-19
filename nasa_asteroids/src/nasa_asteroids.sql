-- Databricks notebook source
declare or replace resp struct<status_code int, text string>;

set var resp = (
  select
    http_request(
      conn => 'nasa_conn',
      method => 'GET',
      path => concat(
        'neo/rest/v1/feed?',
        'start_date=', :date_param,
        '&end_date=', :date_param,
        '&api_key=', secret('secret_scope', 'secret')
      )
    )
);

-- COMMAND ----------

begin
  declare sql_string_explode_array string;
  declare sql_string_replace_where string;
  declare arg_map map<string, string>;
  
  use catalog identifier(:catalog);
  use schema identifier(:schema);
  
  if resp.status_code == 200 then
    -- Explode array to rows and create temp view
    set sql_string_explode_array =
      "create or replace temporary view raw_data as " ||
      "select to_date('"  || :date_param || "') as date, explode(variant_get(parse_json(resp.text), '$.near_earth_objects." || :date_param || "')::array<variant>) as col";
    execute immediate sql_string_explode_array;
    
    -- Extract fields to columns and create temp view
    create or replace temporary view asteroids_src_vw as
    select
      date,
      col:id::string,
      col:name::string,
      col:estimated_diameter.kilometers.estimated_diameter_min::double,
      col:estimated_diameter.kilometers.estimated_diameter_max::double,
      col:is_potentially_hazardous_asteroid::boolean,
      col:nasa_jpl_url::string
    from raw_data;
    
    -- Merge into target table with schema evolution
    merge with schema evolution into identifier(:catalog || '.' || :schema || '.' || 'asteroids') t
    using asteroids_src_vw s
    on t.id = s.id
    and t.date = s.date
    when matched
      then update set *
    when not matched
      then insert *;
  else
    set arg_map = map('errorMessage', resp.text);
    signal user_raised_exception
      set message_arguments = arg_map;
  end if;
end;