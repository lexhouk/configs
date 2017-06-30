Some configuration for linux terminal and programs.

Format for "projects.yml" file:

```
<project_name>:
  info:
    title: <project_title>
  local:
    directory: <path>
    database: <local_database_name>
  remote:
    host: <ip_or_domain_name_for_remote_mysql_server_host>
    user: <remote_database_username>
    password: <remote_database_password>
    database: <remote_database_name>
  <environment>:
    branch: <git_branch_name>
```
