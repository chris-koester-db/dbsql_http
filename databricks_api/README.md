# Databricks API

Examples of how to work with the [Databricks API](https://docs.databricks.com/api/workspace/introduction) using SQL.

## Getting Started

The examples in this folder use an [HTTP connection](https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-syntax-ddl-create-connection) like the one shown below. OAuth is also available. See the documentation for [HTTP connection](https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-syntax-ddl-create-connection) or [AI agent tools](https://docs.databricks.com/aws/en/generative-ai/agent-framework/external-connection-tools) for more details.

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