#/bin/bash
export MAIL_FROM=alerter@d3banking.logicmonitor.com
export MAIL_TO="sjackson@d3banking.com"
export MAIL_TO="stephen.jackson@ncr.com,vdaranouvong@ncr.com"
export SUBJECT="dcr-2399 prod Daily Run procdure dcr-2393"
export MAIL_FILE=/home/sjackson/dba/reports/dcr-2399_prod.txt

mysql --login-path=ftbprod -vv d3app < /home/sjackson/dba/reports/dcr-2399.sql 1> $MAIL_FILE

