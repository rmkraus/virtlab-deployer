FROM localhost/virtlab-deployer-base:latest

# Setup environment
COPY resources/motd /etc/motd
COPY resources/ssh_config /root/.ssh/config
COPY resources/bashrc /root/.bashrc
COPY data.skel /data.skel
RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd' >> /etc/bashrc && \
    echo '[ ! -z "$TERM" -a -r /data/config.sh ] && source /data/config.sh' >> /etc/bashrc && \
    mkdir /app && \
    chmod 0544 /etc/motd && \
    chmod 644 /data.skel/* && \
    chmod 600 /root/.ssh/config
WORKDIR /app
COPY app /app

# Setup startup environment
CMD /app/bin/entry.sh
