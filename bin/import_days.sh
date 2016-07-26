#!/bin/sh
START=`echo $1 | tr -d -`;

for (( c = 0; c < $2; c++ ))
do
  IMPORT_NAME=`date --date="$START +$c day" +%Y_%m_%d`;
  echo $IMPORT_NAME;
  `IMPORT_NAME="$IMPORT_NAME" WHERE="tNotice.add_date = '$IMPORT_NAME' or tNotice.alter_date = '$IMPORT_NAME'" rake chillingeffects:import_notices_via_mysql`
done

