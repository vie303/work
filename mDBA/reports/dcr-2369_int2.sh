#/bin/bash
export MAIL_FROM=alerter@d3banking.logicmonitor.com
export MAIL_TO="sjackson@d3banking.com"
export MAIL_TO="stephen.jackson@ncr.com,stephen.jackson@ncr.com"
export SUBJECT="dcr-2369 int2 Daily Run"
export MAIL_FILE=/home/sjackson/dba/reports/dcr-2369_int2.html

mysql --login-path=ftbstage --verbose ftbstage < /home/sjackson/dba/reports/ach_cleanup.sql > $MAIL_FILE
#(echo -e "Subject: $SUBJECT\nMIME-Version: 1.0\nFrom: $MAIL_FROM\nTo:$MAIL_TO\nContent-Type: text/html\nContent-Disposition: inline\n\n";/bin/cat $MAIL_FILE) | /usr/sbin/sendmail -f  $MAIL_FROM $MAIL_TO

