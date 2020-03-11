FROM docker.io/library/fedora:31

ARG tfvers='0.12.23'

# Install dependencies
RUN dnf update -y && \
    dnf install -y \
        ansible \
        bash \
        less \
        openssh \
        openssh-clients \
        unzip \
        vim \
        wget \
        zip \
        python3-boto

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

# Install Terraform
RUN mkdir /tmp/tf && \
    cd /tmp/tf && \
    wget https://releases.hashicorp.com/terraform/${tfvers}/terraform_${tfvers}_linux_amd64.zip && \
    unzip -qq terraform_${tfvers}_linux_amd64.zip && \
    mv terraform /usr/local/bin && \
    rm -rf /tmp/tf

# Setup startup environment
CMD /app/bin/entry.sh
