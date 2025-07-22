# dbsql_ops

Perform DBSQL management tasks with SQL. Features include:
- Create, update, get, list, delete warehouses
- List query history

This project requires an [HTTP connection](https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-syntax-ddl-create-connection) like the one shown below. OAuth is also available. See the documentation for [HTTP connection](https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-syntax-ddl-create-connection) or [Connect to external HTTP services](https://docs.databricks.com/aws/en/query-federation/http) for more details.

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

## Getting started

1. Install the Databricks CLI from https://docs.databricks.com/dev-tools/cli/install.html

2. Authenticate to your Databricks workspace (if you have not done so already):
    ```
    $ databricks configure
    ```

3. To deploy a development copy of this project, type:
    ```
    $ databricks bundle deploy --target dev
    ```
    (Note that "dev" is the default target, so the `--target` parameter
    is optional here.)

    This deploys everything that's defined for this project.
    For example, the default template would deploy a job called
    `[dev yourname] dbsql_ops_job` to your workspace.
    You can find that job by opening your workpace and clicking on **Workflows**.

4. Similarly, to deploy a production copy, type:
   ```
   $ databricks bundle deploy --target prod
   ```

5. To run a job, use the "run" command:
   ```
   $ databricks bundle run
   ```

6. Optionally, install developer tools such as the Databricks extension for Visual Studio Code from
   https://docs.databricks.com/dev-tools/vscode-ext.html.

7. For documentation on the Databricks Asset Bundles format used
   for this project, and for CI/CD configuration, see
   https://docs.databricks.com/dev-tools/bundles/index.html.
