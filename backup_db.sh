#!/bin/sh

if [ $# -ne 1 ]; then
    echo "specify an arg"
    exit
fi

backup_dir=/media/sf_vbox_shared/db_backups/
backup_name=`date +%Y%m%d`.$1
echo "Backing up to $backup_name"

heroku pg:pull HEROKU_POSTGRESQL_PURPLE_URL $backup_name --app recipesmanager 
pg_dump -d $backup_name > $backup_dir/recipemanager.$backup_name

psql -c 'drop database "latest"'
psql -c "alter database \"$backup_name\" RENAME TO \"latest\""

