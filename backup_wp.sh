#!/bin/sh

if [ $# -ne 1 ]; then
    echo "specify an arg"
    exit
fi

backup_dir=/media/sf_vbox_shared/wp_backups/
backup_name="wp_backup_`date +%Y%m%d`.$1"
echo "Backing up to $backup_name"

ssh gerardsw@gerardsweeney.com "tar zcf $backup_name public_html/wp" 
scp gerardsw@gerardsweeney.com:$backup_name $backup_dir/$backup_name

