#!/bin/sh

######################################################################################################
# Start script: starts single/master or slave node and with/out HA queues

ulimit -n 10240

# if we're "forcing" the hostname, add it to /etc/hosts so erlang can figure it out
if [ "$HOSTNAME" ] ; then
    echo "127.0.0.1      $HOSTNAME" >> /etc/hosts
fi

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

# start the server
exec "$@"

#    rabbitmqctl stop_app
#    rabbitmqctl join_cluster rabbit@${CLUSTER_WITH}
#    rabbitmqctl start_app
