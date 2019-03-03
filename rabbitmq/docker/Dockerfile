FROM balenalib/rpi-raspbian

# Using distro-specfic because cheap/easy
RUN apt-get update && apt-get install rabbitmq-server

# setup
RUN rabbitmq-plugins enable --offline rabbitmq_management && \
	mkdir /data && \
	chown -R rabbitmq:rabbitmq /data && \
	rm -rf /var/lib/apt/lists/*

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
