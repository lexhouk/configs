Some configuration for linux terminal and programs.

# Commands list
<table>
  <thead>
    <tr>
      <th>Command</th>
      <th>Parameters</th>
      <th>Description</th>
      <th>Example</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan="4" align="center">Apache</td>
    </tr>
    <tr>
      <td>eap</td>
      <td>-</td>
      <td>Stop</td>
      <td>eap</td>
    </tr>
    <tr>
      <td>ear</td>
      <td>-</td>
      <td>Restart</td>
      <td>ear</td>
    </tr>
    <tr>
      <td>eas</td>
      <td>-</td>
      <td>Start</td>
      <td>eas</td>
    </tr>
    <tr>
      <td colspan="4" align="center">Composer</td>
    </tr>
    <tr>
      <td>eci</td>
      <td>[any]</td>
      <td>Install</td>
      <td>eci --no-dev</td>
    </tr>
    <tr>
      <td>ecr</td>
      <td>Package name</td>
      <td>Add package</td>
      <td>ecr&nbsp;chmez/d8:^0.8</td>
    </tr>
    <tr>
      <td colspan="4" align="center">Drush</td>
    </tr>
    <tr>
      <td>edscn</td>
      <td>-</td>
      <td>Run cron</td>
      <td>edscn</td>
    </tr>
    <tr>
      <td>edsf</td>
      <td>Module name</td>
      <td>Update feature</td>
      <td>edsf mymodule_blocks</td>
    </tr>
    <tr>
      <td>edsl</td>
      <td>User ID</td>
      <td>Generate a one time login link for the user account</td>
      <td>edsl 10</td>
    </tr>
    <tr>
      <td>edsmi</td>
      <td>Module name(s)</td>
      <td>Install module(s)</td>
      <td>edsmi taxonomy</td>
    </tr>
    <tr>
      <td>edsmu</td>
      <td>Module name(s)</td>
      <td>Uninstall module(s)</td>
      <td>edsmu ban</td>
    </tr>
    <tr>
      <td colspan="4" align="center">Git</td>
    </tr>
    <tr>
      <td>egrv</td>
      <td>Commit hash(es)</td>
      <td>Revert some existing commit(s)</td>
      <td>egrv&nbsp;1a4e902815b1619bcf2c<wbr>c9a284e57c6650ef4098</td>
    </tr>
    <tr>
      <td>egsm</td>
      <td>-</td>
      <td>Add Drupal core as a submodule</td>
      <td>egsm</td>
    </tr>
    <tr>
      <td>egsma</td>
      <td>Module name</td>
      <td>Add a Drupal module as a submodule</td>
      <td>egsma mymodule_blocks</td>
    </tr>
    <tr>
      <td>egsmu</td>
      <td>-</td>
      <td>Update submodules</td>
      <td>egsmu</td>
    </tr>
    <tr>
      <td colspan="4" align="center">MySQL</td>
    </tr>
    <tr>
      <td>emr</td>
      <td>
        <ul>
          <li>Database name (optional)</li>
          <li>SQL-file (optional)</li>
        </ul>
      </td>
      <td>Load database from file or just delete all data and structure if the file is not specified</td>
      <td>emr mydatabase dump.sql</td>
    </tr>
    <tr>
      <td colspan="4" align="center">Operating system</td>
    </tr>
    <tr>
      <td>esc</td>
      <td>-</td>
      <td>Edit commands file</td>
      <td>esc</td>
    </tr>
    <tr>
      <td>escf</td>
      <td>Phrase</td>
      <td>Search a phrase in the commands file</td>
      <td>escf edit</td>
    </tr>
    <tr>
      <td>esh</td>
      <td>-</td>
      <td>Edit hosts file</td>
      <td>esh</td>
    </tr>
    <tr>
      <td>esp</td>
      <td>-</td>
      <td>Set the webserver user as the owner of the Drupal default files directory</td>
      <td>esp</td>
    </tr>
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
  drush:
    uri: <domain_from_multisite_environment>
```
