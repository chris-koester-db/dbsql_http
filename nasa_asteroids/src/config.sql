use catalog identifier(:catalog);
use schema identifier(:schema);

create table if not exists asteroids (
  date date,
  id string,
  name string,
  estimated_diameter_min double,
  estimated_diameter_max double,
  is_potentially_hazardous_asteroid boolean,
  nasa_jpl_url string
) cluster by (date);

-- Number of days to load, including the current day
declare days_to_load string;
set var days_to_load = (select cast(:days_to_load - 1 as int));

declare sql_string string;
set var sql_string = 
  "select explode(sequence((current_date() - interval " || days_to_load || " days), current_date(), interval 1 day)) AS date_param";
execute immediate sql_string;