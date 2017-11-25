#!/bin/sh

######################################################################################################
# Needs more stuff
ulimit -n 10240

######################################################################################################
# set HA policy if present
if [ "$HA_POLICY" ] ; then
    # because we have to wait until the service is running, create a little script that does the command later
    SCRIPT=$(cat << EOF
#!/bin/sh
echo "Waiting 120 seconds to apply HA"
sleep 120
rabbitmqctl set_policy ha-all ${HA_POLICY} '{"ha-mode":"all"}'
EOF
)
    echo "$SCRIPT" > /ha.sh
    chmod a+x /ha.sh
    nohup /ha.sh &
fi

######################################################################################################
# start the server
exec "$@"
