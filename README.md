Some configuration for linux terminal and programs.

# Commands list
<table>
  <thead>
    <tr>
      <th>Command</th>
      <th>Parameter</th>
      <th>Description</th>
      <th>Example</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan="4" align="center">platform.sh</td>
    </tr>
    <tr>
      <td>epsh</td>
      <td>Filename without extension</td>
      <td>Creating dump of database</td>
      <td>epsh master</td>
    </tr>
  </tbody>
</table>

# Format for "projects.yml" file

```
git:
  user: <git_username>
  mail: <git_email>

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
  [dev|live]:
    branch: <git_branch_name>
    ssh:
      host: <ip_or_domain_name_for_remote_ssh_host>
      port: <port_for_remote_ssh_host>
      user: <remote_ssh_username>
      directory: <path>
  docker: <web_server_container_name>
  docker_db: <databases_server_container_name>
```
