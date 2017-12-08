#!/bin/sh
#
# user_app:
# description: Starts and stops the user application daemons
#


# Source function library.
if [ -f /etc/init.d/functions ] ; then
  . /etc/init.d/functions
elif [ -f /etc/rc.d/init.d/functions ] ; then
  . /etc/rc.d/init.d/functions
else
  exit 0
fi

# Avoid using root's TMPDIR
unset TMPDIR

USER_FILE=/mnt/fsuser-1/user

RETVAL=0

start() {
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib

        if [ -f $USER_FILE ] ; then
        cat $USER_FILE |while read ligne
        do
          if [ "$ligne" != "" ]
          then
            COMM=`echo $ligne | grep "#" | wc -l`

            if [ $COMM -eq 0 ]
            then
              SLEEP=`echo $ligne | awk '{print $1}'`
              if [ $SLEEP = "sleep" ]
              then
                DUR=`echo $ligne | awk '{print $2}'`
                sleep $DUR
              else
                echo "Launching application : $ligne"
                eval "${ligne}" >/dev/null 2>&1 &
              fi
            fi
          fi
        done
        fi

        RETVAL=$?
        echo
        return $RETVAL
}

stop() {
        if [ -f $USER_FILE ] ; then
        cat $USER_FILE |while read ligne
        do
          if [ "$ligne" != "" ]
          then
            COMM=`echo $ligne | grep "#" | wc -l`

            if [ $COMM -eq 0 ]
            then
              SLEEP=`echo $ligne | awk '{print $1}'`
              if [ $SLEEP != "sleep" ]
              then
                EXE=`basename $ligne`
                #EXE=`echo $ligne | awk '{print $1}' | awk '{ FS = "/" ; print $NF }`
                if [ "$EXE" != "" ]
                then
                  echo "Shutting down application: $EXE"
                  killproc $EXE
                fi
              fi
            fi
          fi
        done
        fi

        RETVAL=$?
        echo
        return $RETVAL
}

restart() {
        stop
        start
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  restart)
        restart
        ;;
  *)
        echo $"Usage: $0 {start|stop|restart}"
        exit 1
esac

exit $?
