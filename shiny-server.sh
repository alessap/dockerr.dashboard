#!/bin/sh

# Make sure the directory for individual app logs exists
mkdir -p /var/log/shiny-server
chown shiny.shiny /var/log/shiny-server

if [ "$APPLICATION_LOGS_TO_STDOUT" != "false" ];
then
    # push the "real" application logs to stdout with xtail in detached mode
    exec xtail /var/log/shiny-server/ &
fi

# start shiny server
export R_LIBS_USERS=$R_LIBS_USERS:/usr/local/lib/R/site-library/
export R_LIBS_SITE=$R_LIBS_SITE:/usr/local/lib/R/site-library/
exec shiny-server 2>&1

