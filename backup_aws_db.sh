#!/bin/sh

if [ $# -ne 1 ]; then
    echo "specify a suffix for the backup name"
    exit
fi

backup_dir=/media/sf_vbox_shared/db_backups/
backup_name=`date +%Y%m%d`.$1

aws_host=aa1xib12dszo1md.c8diubsyktgp.us-west-2.rds.amazonaws.com
echo "Backing up to $backup_name"

/usr/lib/postgresql/11/bin/pg_dump --host=$aws_host --username=produser --dbname=ebdb -E utf8 -c -O > /tmp/$backup_name.ebdb.sql
createdb $backup_name
psql -p5433 -f /tmp/$backup_name.ebdb.sql --dbname=$backup_name

/usr/lib/postgresql/11/bin/pg_dump -d $backup_name > $backup_dir/recipemanager.$backup_name

psql -c 'drop database "latest"'
psql -c "alter database \"$backup_name\" RENAME TO \"latest\""

rm -f /tmp/$backup_name.ebdb.sql
