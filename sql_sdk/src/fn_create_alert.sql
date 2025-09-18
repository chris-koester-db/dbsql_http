use catalog identifier(:catalog);
use schema identifier(:schema);

CREATE OR REPLACE FUNCTION create_alert(
  -- Required
  display_name STRING,
  query_text STRING,
  warehouse_id STRING,

  -- Alert config
  comparison_operator STRING DEFAULT 'GREATER_THAN',
  threshold_value DOUBLE DEFAULT 0.0,
  empty_result_state STRING DEFAULT 'UNKNOWN',

  -- Notification
  user_email STRING DEFAULT NULL,
  notify_on_ok STRING DEFAULT 'true',
  retrigger_seconds INT DEFAULT 0,

  -- Schedule
  cron_schedule STRING DEFAULT '0 */15 * * * ?',
  timezone_id STRING DEFAULT 'UTC',
  pause_status STRING DEFAULT 'UNPAUSED',

  -- Optional
  parent_path STRING DEFAULT '/Workspace/Users/',
  source_aggregation STRING DEFAULT 'FIRST',
  source_display STRING DEFAULT 'value',
  source_name STRING DEFAULT 'value'
)
COMMENT 'Creates an alert. https://docs.databricks.com/api/workspace/alerts/create'
RETURN
WITH payload AS (
  SELECT
    to_json(
      named_struct(
        'display_name',         display_name,
        'query_text',           query_text,          -- safely escaped by to_json
        'parent_path',          parent_path,
        'warehouse_id',         warehouse_id,
        'evaluation', named_struct(
          'comparison_operator', comparison_operator,
          'empty_result_state',  empty_result_state,
          'notification', named_struct(
            'notify_on_ok',      notify_on_ok,
            'retrigger_seconds', retrigger_seconds,
            'subscriptions',
              CASE
                WHEN user_email IS NOT NULL
                  THEN array(named_struct('user_email', user_email))
                ELSE array()   -- empty array if no email
              END
          ),
          'source', named_struct(
            'aggregation', source_aggregation,
            'display',     source_display,
            'name',        source_name
          ),
          'threshold', named_struct(
            'value', named_struct('double_value', threshold_value)
          )
        ),
        'schedule', named_struct(
          'pause_status',         pause_status,
          'quartz_cron_schedule', cron_schedule,
          'timezone_id',          timezone_id
        )
      )
    ) AS json_body
)
SELECT
  http_request(
    conn   => 'databricks_api',
    method => 'POST',
    path   => '2.0/alerts',
    json   => json_body
  ).text AS resp
FROM payload
|> select
     from_json(
       resp,
       'STRUCT<condition: STRUCT<op: STRING, operand: STRUCT<column: STRUCT<name: STRING>>, threshold: STRUCT<value: STRUCT<double_value: BIGINT>>>, create_time: STRING, display_name: STRING, id: STRING, lifecycle_state: STRING, owner_user_name: STRING, parent_path: STRING, query_id: STRING, seconds_to_retrigger: BIGINT, state: STRING, update_time: STRING>'
     );