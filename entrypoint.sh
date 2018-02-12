#!/bin/bash

sleep infinity & PID=$!
trap "kill $PID" INT TERM

case "$1" in
    'start')
        if [ ! -e /home/jet/jet-setup.cf ]; then
            echo "Firt run setup.."
            sudo -u jet /home/jet/bin/setup-jet.sh
            /home/jet/bin/setup-supervisor.sh
            touch /home/jet/jet-setup.cf
        fi
        echo "Starting application.."
        #service start apache2
        #service start supervisord
        wait
        echo "..exiting"
        service stop supervisord
        service stop apache2
    ;;
    *)
        echo "Called with unhandled arg: $1"
        exec /bin/bash
    ;;
esac

