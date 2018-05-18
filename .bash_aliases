# Message

show_message() {
  local now=$(date +"%T.%N")
  local set_time_color='\e[0;33m'
  local set_app_color='\e[96m'
  local del_color='\e[0m'
  local msg="${set_time_color}$now${del_color} "

  if [ "$#" == 1 ]; then
    msg+="> $1"
  else
    local text="$2"
    local reg='^\w+ing(|\s[^\.]+)$'

    msg+="${set_app_color}< $1 >${del_color} ${text}"

    if [[ $text =~ $reg ]]; then
      msg+="..."
    fi
  fi

  echo -e $msg
}

# Parse projects info file.

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

# Get project settings prefix.

get_project() {
  eval $(parse_yaml)
  local conf=$(( set -o posix ; set ) | cat | grep '^project\_[a-z0-9]*\_local\_directory\='$(pwd)'$')

  if [ -z $conf ]; then
    echo ''
  else
    echo 'project_'$(echo $conf | sed 's/^project\_\([^\_]*\).*$/\1/')'_'
  fi
}

# Getting variable value.

get() {
  eval $(parse_yaml)
  echo ${!1}
}

# SSH

execute_remote() {
  local project=$(get_project)

  if ! [ -z $project ]; then
    local ssh="${project}$1_ssh_"
    local host=$(get "${ssh}host")

    if ! [ -z $host ]; then
      local user=$(get "${ssh}user")

      if ! [ -z $user ]; then
        local title=$(get "${project}info_title")
        show_message "SSH" "Connecting to \"$1\" host of \"${title}\" project"

        local port=$(get "${ssh}port")

        if [ -z $port ]; then
          port=22
        fi

        local directory=$(get "${ssh}directory")

        if ! [ -z $directory ]; then
          ssh -p ${port} ${user}@${host} -t "cd ${directory} ; bash"
        else
          ssh -p ${port} ${user}@${host}
        fi
      else
        show_message "SSH" "User not defined!"
      fi
    else
      show_message "SSH" "Host not defined!"
    fi
  else
    show_message "Undefined project!"
  fi
}

alias erd="execute_remote dev"
alias erl="execute_remote live"

execute_remote_dev_transfer() {
  local project=$(get_project)

  if ! [ -z $project ]; then
    local host=$(get "${project}dev_ssh_host")

    if ! [ -z $host ]; then
      local user=$(get "${project}dev_ssh_user")

      if ! [ -z $user ]; then
        local title=$(get "${project}info_title")
        show_message "SSH" "Downloading file(s) from development host of \"${title}\" project"
        scp ${user}@${host}:$1 .
      else
        show_message "SSH" "User not defined!"
      fi
    else
      show_message "SSH" "Host not defined!"
    fi
  else
    show_message "Undefined project!"
  fi
}

alias erdt="execute_remote_dev_transfer $1"

# Composer

execute_composer_install() {
  show_message "Composer" "Installing"
  composer install
}

alias eci=execute_composer_install

execute_composer_update() {
  show_message "Composer" "Updating"
  composer update
}

alias ecu=execute_composer_update

# GIT

alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gba='git branch -a '
alias gc='git commit -m '
alias gd='git diff '

execute_git_branch() {
  show_message "Git" "Switching to \"$1\" branch"
  git checkout $1
}

alias egbs=execute_git_branch

execute_git_branch_enviroment() {
  local project=$(get_project)
  local branch="$1"

  if ! [ -z $project ]; then
    local special_branch=$(get "${project}$2_branch")

    if ! [ -z $special_branch ]; then
      branch=$special_branch
    fi
  fi

  execute_git_branch $branch
}

alias egbd='execute_git_branch_enviroment dev dev'
alias egbm='execute_git_branch_enviroment master live'

execute_git_changes() {
  if [ "$#" == 0 ]; then
    show_message "Git" "Canceling all changes"
    git checkout .
  else
    show_message "Git" "Canceling some changes"
    git checkout $@
  fi
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
  show_message "Git" "Change origin URL to remote repository"
  git remote set-url origin $1
}

alias egrc=execute_git_remote_change

execute_git_clone() {
  local remote=""
  local directory=""
  local branch=""
  local user=""
  local mail=""
  local email=""

  if [ -d .git ]; then
    show_message "Git" "Recloning"

    remote=$(git remote get-url origin)
    directory=${PWD##*/}
    branch=$(git rev-parse --abbrev-ref HEAD)
    user=$(git config user.name)
    mail=$(git config user.mail)
    email=$(git config user.email)

    cd ..
    sudo rm -rf $directory
  else
    show_message "Git" "Cloning"

    remote=$1
    directory=$2
  fi

  git clone $remote $directory
  cd $directory
  git config core.fileMode false

  if ! [ -z $branch ]; then
    execute_git_branch $branch
    execute_git_pull $branch

    git config user.name "${user}"
    git config user.mail $mail
    git config user.email $email
  fi
}

alias egc=execute_git_clone

alias egb='git checkout -b '
alias egcp='git cherry-pick '
alias egcpc='git cherry-pick --continue '
alias egfm='git config core.fileMode '
alias egfmd='git config core.fileMode false '

execute_git_fetch() {
  show_message "Git" "Fetching"
  git fetch
}

alias egf=execute_git_fetch

alias egm='git merge '

execute_git_push() {
  show_message "Git" "Pushing to \"$1\" branch"
  git push origin $1
}

alias egh=execute_git_push
alias eghm='execute_git_push master'

execute_git_push_dev() {
  local project=$(get_project)
  local branch="dev"

  if ! [ -z $project ]; then
    local special_branch=$(get "${project}dev_branch")

    if ! [ -z $special_branch ]; then
      branch=$special_branch
    fi
  fi

  execute_git_push $branch
}

alias eghd=execute_git_push_dev

execute_git_pull() {
  show_message "Git" "Pulling from \"$1\" branch"
  git pull origin $1
}

alias egl=execute_git_pull

execute_git_pull_enviroment() {
  local project=$(get_project)
  local branch="$1"

  if ! [ -z $project ]; then
    local special_branch=$(get "${project}$2_branch")

    if ! [ -z $special_branch ]; then
      branch=$special_branch
    fi
  fi

  execute_git_pull $branch
}

alias egld='execute_git_pull_enviroment dev dev'
alias eglm='execute_git_pull_enviroment master live'

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

execute_git_user() {
  local name=$(git config user.name)
  local email=$(git config user.email)
  show_message "Git" "Owner of future commits will be ${name} <${email}>"
}

alias egu=execute_git_user

# Docker

alias edrs='sudo service docker start '
alias edrp='sudo service docker stop '

docker_clear() {
  show_message "Docker" "Stoping containers"
  docker stop $(docker ps -q)
  show_message "Docker" "Removing containers"
  docker rm -f $(docker ps -a -q)
  show_message "Docker" "Removing images"
  docker rmi -f $(docker images -a -q)
  show_message "Docker" "Removing volumes"
  docker volume rm $(docker volume ls -q)
  show_message "Docker" "Removing networks"
  docker network rm $(docker network ls | tail -n+2 | awk '{if($2 !~ /bridge|none|host/){ print $1 }}')
  show_message "Docker" "Results"
  docker ps -a
  docker images -a
  docker volume ls
}

alias edrc=docker_clear

execute_docker_list() {
  show_message "Docker" "Getting list of running containers"
  docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Image}}\t{{.RunningFor}}\t{{.Status}}"
}

alias edrl=execute_docker_list

alias edre='docker exec -it '
alias edra='sudo chmod +x $(find . -name "*.sh") '

execute_docker_up() {
  show_message "Docker" "Upping"
  docker-compose up -d
}

alias edru=execute_docker_up

execute_docker_down() {
  show_message "Docker" "Downing"
  docker-compose down
}

alias edrd=execute_docker_down

execute_docker() {
  local project=$(get_project)

  if ! [ -z $project ]; then
    local container=$(get "${project}docker")

    if ! [ -z $container ]; then
      edre $container $@
      return
    fi
  fi

  $@
}

execute_docker_database_container() {
  local project=$(get_project)

  if ! [ -z $project ]; then
    local container=$(get "${project}docker_db")

    if ! [ -z $container ]; then
      echo $container
      return
    fi
  fi
}

# MySQL

alias ems='sudo service mysql start '
alias emp='sudo service mysql stop '
alias em='mysql -u root -proot '

mysql_import() {
  show_message "MySQL" "Importing database"
  pv $2 | mysql -u root -proot $1
}

alias emi=mysql_import

mysql_export() {
  mysqldump -u root -proot $1 > $2.sql
  show_message "MySQL" "Created dump for database called $1 in file $2.sql"
}

alias eme=mysql_export

execute_mysql_create_db() {
  show_message "MySQL" "Creating \"$1\" database"

  local container=$(execute_docker_database_container)
  local database=$1

  if [ -z $container ]; then
    mysql -u root -proot -e "create database ${database}"
  else
    docker exec -it $container mysql -u root -proot -e "create database ${database}"
  fi

  show_message "MySQL" "Created database called \"$1\"."
}

alias emc=execute_mysql_create_db

execute_mysql_drop_db() {
  show_message "MySQL" "Deleting \"$1\" database"

  local container=$(execute_docker_database_container)
  local database=$1

  if [ -z $container ]; then
    mysql -u root -proot -e "drop database ${database}"
  else
    docker exec -it $container mysql -u root -proot -e "drop database ${database}"
  fi
}

alias emd=execute_mysql_drop_db

execute_mysql_reload() {
  local database=$1

  emd $database
  emc $database

  if [ -z "$2" ]; then
    return
  fi

  local container=$(execute_docker_database_container)
  local dump=$2

  show_message "MySQL" "Loading \"${database}\" database from \"${dump}\" file"

  if [ -z $container ]; then
    pv $dump | mysql -u root -proot $database
  else
    docker exec -it $container bash -c "mysql -u root -proot ${database} < ${dump}"
  fi

  show_message "MySQL" "Recreated \"${database}\" database and load data from \"${dump}\" dump file."
}

alias emr=execute_mysql_reload

mysql_create_user() {
  mysql -u root -proot -e "CREATE USER '$1'@'localhost' IDENTIFIED BY '$2'"
  mysql -u root -proot -e "GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost'"
  mysql -u root -proot -e "FLUSH PRIVILEGES"
  show_message "MySQL" "Created user \"$1\" for \"$1\" database."
}

alias emu=mysql_create_user

mysql_create_user_special() {
  mysql -u root -proot -e "CREATE USER '$2'@'localhost' IDENTIFIED BY '$3'"
  mysql -u root -proot -e "GRANT ALL PRIVILEGES ON $1.* TO '$2'@'localhost'"
  mysql -u root -proot -e "FLUSH PRIVILEGES"
  show_message "MySQL" "Created user \"$2\" for \"$1\" database."
}

alias emus=mysql_create_user_special

# Drush

execute_drush() {
  execute_docker drush $@
}

execute_drush_execute() {
  show_message "Drush" "Executing any command"
  execute_drush $@
}

alias eds=execute_drush_execute

execute_drush_clear() {
  show_message "Drush" "Clearing all caches"

  local project=$(get_project)
  local docker=0

  if ! [ -z $project ]; then
    local container=$(get "${project}docker")

    if ! [ -z $container ]; then
      edre $container drush cr
      docker=1
    fi
  fi

  if [ $docker == 0 ]; then
    if [ -e index.php ]; then
      if [ -e core ]; then
        drush cr
      else
        drush cc all
      fi
    else
      show_message "Site not found!"
    fi
  fi
}

alias edsc=execute_drush_clear

execute_drush_clear_root() {
  show_message "Drush" "Clearing all caches by root"
  execute_docker sudo drush cc all
}

alias edscr=execute_drush_clear_root

execute_drush_user_login() {
  show_message "Drush" "Display a one time login link for the given user account (defaults to uid 1)."
  execute_drush uli
}

alias edsu=execute_drush_user_login

execute_drush_uli() {
  execute_drush uli --uid=$1
}

alias edsus=execute_drush_uli

execute_drush_uli_uid_no_browser() {
  execute_drush uli --uid=$1 --no-browser
}

alias edsusn=execute_drush_uli_uid_no_browser

execute_drush_dump() {
  show_message "Drush" "Creating dump of database"
  execute_drush sql-dump --result-file=$1.sql
}

alias edsd=execute_drush_dump

execute_drush_status() {
  show_message "Drush" "Getting status"
  execute_drush status
}

alias edss=execute_drush_status

execute_drush_status_database() {
  show_message "Drush" "Getting database name"
  execute_drush status --fields=db-name
}

alias edssd=execute_drush_status_database

# Apache

execute_apache_start() {
  show_message "Apache" "Starting"
  sudo service apache2 start
}

alias eas=execute_apache_start

execute_apache_restart() {
  show_message "Apache" "Restarting"
  sudo service apache2 restart
}

alias ear=execute_apache_restart

execute_apache_stop() {
  show_message "Apache" "Stopping"
  sudo service apache2 stop
}

alias eap=execute_apache_stop

alias eae='sudo a2ensite '
alias ead='sudo a2dissite '

# Tar

execute_tar_extract() {
  show_message "Tar" "Extracting"
  local file=$1

  if [[ $file =~ \.gz$ ]]; then
    tar zxfv ${file}
  else
    tar -xvf ${file}
  fi
}

alias ete=execute_tar_extract

# Drupal

execute_drupal_db() {
  show_message "Drupal" "Getting database name"
  cat sites/default/settings.php | grep "'database'"
}

alias edld=execute_drupal_db

execute_drupal_update() {
  show_message "Drupal" "Updating module or theme"
  if ! [ -z "$2" ]; then
    rm -rf $2
    wget $1$2$3
    tar zxfv $2$3
    rm $2$3
  else
    rm -rf $1
    mv $(find ~/Downloads -name "${1}*") .
    local file=$(ls ${1}*.tar*)
    ete $file
    rm $file
  fi
}

alias edlu=execute_drupal_update

# Projects data

execute_project() {
  local project=$(get_project)

  if [ -z $project ]; then
    show_message "Undefined project!"
  else
    local title=$(get "${project}info_title")
    show_message $title "Reinstalling site"
    eval "execute_${project%_*}"
  fi
}

alias ep=execute_project

execute_project_update_all() {
  local project=$(get_project)

  if [ -z $project ]; then
    show_message "Undefined project!"
  else
    local title=$(get "${project}info_title")
    show_message 'Updating "'${title}'" project database'
    local remote="${project}remote_"
    local host="${remote}host"
    local user="${remote}user"
    local password="${remote}password"
    local database="${remote}database"
    mysqldump -h $(get $host) -u $(get $user) -p$(get $password) $(get $database) > db.sql
    emr $(get "${project}local_database") db.sql
    rm db.sql
  fi
}

alias epua=execute_project_update_all

# Others

execute_system_deploy() {
  show_message "System" "Deploying"

  local project=$(get_project)

  if [ -z $project ]; then
    show_message "Undefined project!"
    return
  fi

  project+="local_deploy_"
  local steps=$(get "${project}amount")

  if [ -z $steps ]; then
    return
  fi

  local step=1

  while [ $step -le $steps ]; do
    echo $(get "${project}steps_${step}_type")
    ((step++))
  done
}

alias esd=execute_system_deploy

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
    show_message "Changing enviroment from local to Docker"
    eap
    emp
    edrs
  else
    show_message "Changing enviroment from Docker to local"
    edrp
    eas
    ems
  fi
}

alias ese=execute_system_enviroment

execute_system_space() {
  show_message "System" "Getting free space on the disks"
  df -h --output=source,target,avail | grep /dev/sd
}

alias ess=execute_system_space

alias q='exit'
