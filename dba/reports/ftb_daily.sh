#/bin/bash
export MAIL_FROM=alerter@d3banking.logicmonitor.com
#export MAIL_TO="sjackson@d3banking.com,tbahmer@d3banking.com"
export MAIL_TO="stephen.jackson@ncr.com,stephen.jackson@ncr.com"
export SUBJECT="FTB Daily"
export MAIL_FILE=/home/sjackson/dba/reports/ftb_daily_out.html

mysql --login-path=ftbprod --html --verbose < /home/sjackson/dba/reports/ftb_daily.sql > $MAIL_FILE

(echo -e "Subject: $SUBJECT\nMIME-Version: 1.0\nFrom: $MAIL_FROM\nTo:$MAIL_TO\nContent-Type: text/html\nContent-Disposition: inline\n\n";/bin/cat $MAIL_FILE) | /usr/sbin/sendmail -f  $MAIL_FROM $MAIL_TO

