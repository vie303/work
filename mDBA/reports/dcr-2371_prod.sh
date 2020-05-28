#/bin/bash
export MAIL_FROM=alerter@d3banking.logicmonitor.com
export MAIL_TO="sjackson@d3banking.com"
export MAIL_TO="stephen.jackson@ncr.com,vdaranouvong@ncr.com"
export SUBJECT="dcr-2371 prod Daily Run"
export MAIL_FILE=/home/sjackson/dba/reports/dcr-2371_prod.txt

#mysql --login-path=ftbsuntrust --html --verbose < /home/sjackson/dba/reports/ftb_daily.sql > $MAIL_FILE
mysql --login-path=ftbprod -vv d3app < /home/sjackson/dba/reports/ach_cleanup.sql > $MAIL_FILE
#(echo -e "Subject: $SUBJECT\nMIME-Version: 1.0\nFrom: $MAIL_FROM\nTo:$MAIL_TO\nContent-Type: text/html\nContent-Disposition: inline\n\n";/bin/cat $MAIL_FILE) | /usr/sbin/sendmail -f  $MAIL_FROM $MAIL_TO

