#!/bin/sh

SCRIPT=`readlink -f "$0"`
SCRIPTDIR=`dirname "$SCRIPT"`
BASEDIR=`readlink -f "${SCRIPTDIR}/../"`

LOGDIR="$HOME/local/var/log"
RUNDIR="$HOME/local/var/run"

if [ ! -d $LOGDIR ]
then
    echo "Creating '$LOGDIR'";
    mkdir -p $LOGDIR;
    chmod 775 $LOGDIR;
fi

if [ ! -d $RUNDIR ]
then
    echo "Creating '$RUNDIR'";
    mkdir -p $RUNDIR;
    chmod 775 $RUNDIR;
fi

MY_APP="altpan"
MY_HOST_PORT="127.0.0.1:5002"

SERVER_CMD=`which start_server`
SERVER_OPTS="--dir=${BASEDIR} --signal-on-hup=QUIT --pid-file=${RUNDIR}/${MY_APP}.pid --status-file=${RUNDIR}/${MY_APP}.status --log-file=${LOGDIR}/${MY_APP}.log"


ss_start () {
    ${SERVER_CMD} ${SERVER_OPTS} \
        --port=${MY_HOST_PORT} --daemonize --enable-auto-restart -- \
        starman --listen ${MY_HOST_PORT} app.psgi
}

ss_restart () {
    ${SERVER_CMD} ${SERVER_OPTS} \
        --port=${MY_HOST_PORT} --daemonize --enable-auto-restart --restart
}

ss_stop () {
    ${SERVER_CMD} ${SERVER_OPTS} --stop
}

ss_usage () {
    echo "USAGE $0 [start|restart|stop]"
}

case "$1" in
start)   ss_start ;;
restart) ss_restart ;;
stop)    ss_stop ;;
*)       ss_usage ; exit 1 ;;
esac
