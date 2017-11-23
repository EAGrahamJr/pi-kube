FROM resin/rpi-raspbian:jessie

# get rabbit from whatever was downloaded to the host
COPY rabbitmq-server* rabbit.deb

# install the rabbit, use apt to pick up dependencies, then clean up the mess
RUN apt-get update -qq && \
    dpkg -i --force-depends rabbit.deb && \
    apt-get install -f --no-install-recommends -yqq && \
    apt-get install --no-install-recommends -yqq dnsutils && \
    apt-get autoremove -yqq && \
    rm -rf /var/lib/apt/lists/* /rabbit.deb

# copy in the plugin
ADD plugins/* /usr/lib/rabbitmq/lib/rabbitmq_server-3.6.14/plugins/

# setup
RUN rabbitmq-plugins enable --offline rabbitmq_management autocluster && \
	mkdir /data && \
	chown -R rabbitmq:rabbitmq /data

# log to STDOUT
ENV RABBITMQ_LOGS=- RABBITMQ_SASL_LOGS=-

# Define mount points and set the data directory to point to it
# Note: if this is mounted (see next), persistent stores can be used
VOLUME "/data"
ENV  RABBITMQ_MNESIA_BASE=/data

# Expose ports.
EXPOSE 4369 5671 5672 15672 25672

# copy in the start script and configs
COPY rabbitmq.config /etc/rabbitmq
COPY start.sh /
ENTRYPOINT [ "/start.sh" ]

# starts the server
CMD ["rabbitmq-server"]
