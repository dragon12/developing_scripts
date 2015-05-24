#!/bin/bash

`dirname $0`/retrieve_prod_db.sh

echo "Uploading..."
mysql -u root development < prod.sql
echo "Uploaded!"

