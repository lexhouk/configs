# Message

show_message() {
  now=$(date +"%T.%N")
  set_color='\e[0;33m'
  del_color='\e[0m'
  echo -e "${set_color}$now${del_color} > $1"
}

# GIT

alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gba='git branch -a '
alias gc='git commit -m '
alias gd='git diff '

execute_git_branch() {
  show_message "Git: switching to \"$1\" branch..."
  git checkout $1
}

alias egbs=execute_git_branch
alias egbm='execute_git_branch master'
alias egbd='execute_git_branch dev'

execute_git_changes() {
  show_message "Git: canceling changes..."
  git checkout $@
}

alias egch=execute_git_changes

alias gk='gitk --all&'
alias gx='gitx --all'
alias gf='git fetch '
alias gl='git log '

git_init() {
  git init
  git config core.fileMode false
}

alias egi=git_init

alias egr='git rm '
alias egrs='git remote -v'
alias egra='git remote add '
alias egrao='git remote add origin '

execute_git_remote_change() {
  show_message "Git: change origin URL to remote repository..."
  git remote set-url origin $1
}

alias egrc=execute_git_remote_change

git_clone() {
  git clone $1 $2
  cd $2
  git config core.fileMode false
}

alias egc=git_clone

alias egb='git checkout -b '
alias egcp='git cherry-pick '
alias egcpc='git cherry-pick --continue '
alias egfm='git config core.fileMode '
alias egfmd='git config core.fileMode false '

execute_git_fetch() {
  show_message "Git: fetching..."
  git fetch
}

alias egf=execute_git_fetch

alias egm='git merge '

execute_git_push() {
  show_message "Git: pushing to \"$1\" branch..."
  git push origin $1
}

alias egh=execute_git_push
alias eghm='execute_git_push master'
alias eghd='execute_git_push dev'

execute_git_pull() {
  show_message "Git: pulling from \"$1\" branch..."
  git pull origin $1
}

alias egl=execute_git_pull
alias eglm='execute_git_pull master'
alias egld='execute_git_pull dev'

alias egl-f2f-ts='git pull origin master '

git_submodule_add_core() {
  git submodule add --branch 7.x http://git.drupal.org/project/drupal.git htdocs
}

alias egs=git_submodule_add_core

git_submodule_add_module() {
  git submodule add --branch 7.x-$2.x http://git.drupal.org/project/$1.git sites/all/modules/contrib/$1
}

alias egsa=git_submodule_add_module
alias egsu='git submodule update --init '

# MySQL

alias ems='sudo service mysql start '
alias emp='sudo service mysql stop '
alias em='mysql -u root -proot '

mysql_import() {
  pv $2 | mysql -u root -proot $1
}

alias emi=mysql_import

mysql_export() {
  mysqldump -u root -proot $1 > $2.sql
  show_message "Created dump for database called $1 in file $2.sql"
}

alias eme=mysql_export

mysql_create_db() {
  mysql -u root -proot -e "create database $1"
  show_message "Created database called \"$1\"."
}

alias emc=mysql_create_db

mysql_drop_db() {
  show_message "Deleting \"$1\" database..."
  mysql -u root -proot -e "drop database $1"
}

alias emd=mysql_drop_db

execute_mysql_reload() {
  emd $1
  emc $1

  if [ -e "$2" ]; then
    show_message "Loading \"$1\" database from \"$2\" file..."
    pv $2 | mysql -u root -proot $1
    show_message "Recreated \"$1\" database and load data from \"$2\" dump file."
  fi
}

alias emr=execute_mysql_reload

mysql_create_user() {
  mysql -u root -proot -e "CREATE USER '$1'@'localhost' IDENTIFIED BY '$2'"
  mysql -u root -proot -e "GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost'"
  mysql -u root -proot -e "FLUSH PRIVILEGES"
  show_message "Created user \"$1\" for \"$1\" database."
}

alias emu=mysql_create_user

mysql_create_user_special() {
  mysql -u root -proot -e "CREATE USER '$2'@'localhost' IDENTIFIED BY '$3'"
  mysql -u root -proot -e "GRANT ALL PRIVILEGES ON $1.* TO '$2'@'localhost'"
  mysql -u root -proot -e "FLUSH PRIVILEGES"
  show_message "Created user \"$2\" for \"$1\" database."
}

alias emus=mysql_create_user_special

# Drush

drush_clear_message() {
  show_message "Clearing all caches..."
}

drush_clear() {
  drush_clear_message

  if [ -e core ]; then
    drush cr
  else
    drush cc all
  fi
}

alias edc=drush_clear

root_drush_clear() {
  show_message "Clearing all caches..."
  sudo drush cc all
}

alias erdc=root_drush_clear

drush_user_login() {
  show_message "Display a one time login link for the given user account (defaults to uid 1)."
  drush uli
}

alias edu=drush_user_login

drush_uli() {
  drush uli --uid=$1
}

alias edus=drush_uli

drush_uli_uid_no_browser() {
  drush uli --uid=$1 --no-browser
}

alias edusn=drush_uli_uid_no_browser

drush_dump() {
  drush sql-dump --result-file=$1.sql
}

alias edd=drush_dump

alias eds='drush status '

drush_status_database() {
  show_message "Provides a birds-eye view of the current Drupal installation, if any."
  drush status --fields=db-name
}

alias edsd=drush_status_database

# Apache

alias eas='sudo service apache2 start '
alias ear='sudo service apache2 restart '
alias eap='sudo service apache2 stop '
alias eae='sudo a2ensite '
alias ead='sudo a2dissite '

# Tar

alias ete='tar zxfv '

# Drupal

drupal_db() {
  cat sites/default/settings.php | grep "'database'"
}

alias ecd=drupal_db

execute_cms_update() {
  if ! [ -z "$2" ]; then
    rm -rf $2
    wget $1$2$3
    tar zxfv $2$3
    rm $2$3
  else
    rm -rf $1
    mv ~/Downloads/"$1".tar.gz .
    ete "$1".tar.gz
    rm "$1".tar.gz
  fi
}

alias ecu=execute_cms_update

# Docker

alias edrs='sudo service docker start '
alias edrp='sudo service docker stop '

docker_clear() {
  show_message "Docker: stoping containers..."
  docker stop $(docker ps -q)
  show_message "Docker: removing containers..."
  docker rm -f $(docker ps -a -q)
  show_message "Docker: removing images..."
  docker rmi -f $(docker images -a -q)
  show_message "Docker: removing volumes..."
  docker volume rm $(docker volume ls -q)
  show_message "Docker: results..."
  docker ps -a
  docker images -a
  docker volume ls
}

alias edrc=docker_clear
alias edrl='docker ps '
alias edre='docker exec -it '
alias edra='sudo chmod +x $(find . -name "*.sh") '

# Projects data

parse_yaml() {
  local file_name="$HOME"'/projects.yml'
  local prefix='project_'
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $file_name |
  awk -F$fs '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
      vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
      printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
    }
  }'
}

execute_project_update_all() {
  eval $(parse_yaml)
  local conf=$(( set -o posix ; set ) | cat | grep '^project\_[a-z]*\_local\_directory\='$(pwd)'$')

  if [ -z $conf ]; then
    show_message "Undefined project!"
  else
    local project='project_'$(echo $conf | sed 's/^project\_\([^\_]*\).*$/\1/')'_'
    local title="$project"
    title+="info_title"
    show_message 'Updating "'${!title}'" project database...'
    local remote="$project"
    remote+="remote_"
    local host="$remote"
    host+="host"
    local user="$remote"
    user+="user"
    local password="$remote"
    password+="password"
    local database="$remote"
    database+="database"
    mysqldump -h ${!host} -u ${!user} -p${!password} ${!database} > db.sql
    local database="$project"
    database+="local_database"
    emr ${!database} db.sql
    rm db.sql
  fi
}

alias epua=execute_project_update_all

# Others

alias esf='cd /hdd/www/'
alias esp='sudo chown -R www-data:www-data sites/default '
alias esc='nano ~/.bash_aliases'

search_command() {
  cat ~/.bash_aliases | grep "$1"
}

alias escf=search_command

alias esh='sudo gedit /etc/hosts'

execute_system_enviroment() {
  STATUS=$(sudo service docker status)
  if [ "$STATUS" == "docker stop/waiting" ]; then
    show_message "Changing enviroment from local to Docker..."
    eap
    emp
    edrs
  else
    show_message "Changing enviroment from Docker to local..."
    edrp
    eas
    ems
  fi
}

alias ese=execute_system_enviroment

alias q='exit'
