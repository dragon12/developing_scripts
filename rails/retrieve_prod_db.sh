#!/bin/bash

arg=$0

ssh -v -v gerardsw@gerardsweeney.com 'rm -f prod.sql; mysqldump --user=gerardsw_recipes --password=$arg gerardsw_recipes> prod.sql'
scp gerardsw@gerardsweeney.com:prod.sql .

echo "File copied back to prod.sql"

