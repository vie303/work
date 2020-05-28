#/bin/bash
export MAIL_FROM=alerter@d3banking.logicmonitor.com
export MAIL_TO="sjackson@d3banking.com"
export MAIL_TO="stephen.jackson@ncr.com,vdaranouvong@ncr.com"
export SUBJECT="dcr-2357 prod Daily Run "
export MAIL_FILE=/home/sjackson/dba/reports/dcr-2357_prod.txt

mysql --login-path=ftbprod -vv  d3app < /home/sjackson/dba/reports/dcr-2357.sql 1> $MAIL_FILE

