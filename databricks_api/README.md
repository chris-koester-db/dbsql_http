# Databricks API

Examples of how to work with the [Databricks API](https://docs.databricks.com/api/workspace/introduction) using SQL. The Databricks SQL functions and examples have been moved to the [dbsql_ops folder](../dbsql_ops).

## Getting Started

The examples in this folder use an [HTTP connection](https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-syntax-ddl-create-connection) like the one shown below. OAuth is also available. See the documentation for [HTTP connection](https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-syntax-ddl-create-connection) or [Connect to external HTTP services](https://docs.databricks.com/aws/en/query-federation/http) for more details.

```sql
create connection if not exists databricks_api
type HTTP
options (
  host 'https://cust-success.cloud.databricks.com',
  port '443',
  base_path '/api/',
  bearer_token 'your_token' -- Personal access token
);
```
