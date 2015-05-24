#!/bin/bash

ssh -v -v gerardsw@gerardsweeney.com 'rm -f prod.sql; mysqldump --user=gerardsw_recipes --password=Hivviciv8jh! gerardsw_recipes> prod.sql'
scp gerardsw@gerardsweeney.com:prod.sql .

echo "File copied back to prod.sql"

