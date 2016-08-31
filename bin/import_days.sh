#!/usr/bin/env bash
START=`echo $1 | tr -d -`;

for (( c = 0; c < $2; c++ ))
do
  IMPORT_NAME=`date --date="$START +$c day" +%Y-%m-%d`;
  echo $IMPORT_NAME;
  `SKIP_RAILS_ADMIN_INITIALIZER=true IMPORT_NAME="$IMPORT_NAME" WHERE="tNotice.add_date like '$IMPORT_NAME%' or tNotice.alter_date like '$IMPORT_NAME%'" rake chillingeffects:import_notices_via_mysql`
done

