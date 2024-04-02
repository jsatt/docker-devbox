FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
       locales locales-all apt-utils \
       sudo whois man-db apt-transport-https ca-certificates curl gnupg-agent software-properties-common \
    && yes | unminimize \
    && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en

RUN \
    # Git PPA
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xe1dd270288b4e6030699e45fa1715d88e1df1f24" | gpg --dearmor -o /etc/apt/trusted.gpg.d/git-core.gpg \
    && echo "deb [signed-by=/etc/apt/trusted.gpg.d/git-core.gpg] https://ppa.launchpadcontent.net/git-core/ppa/ubuntu/ jammy main" > /etc/apt/sources.list.d/git-core.list \
    # Python PPA
    && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xf23c5a6cf475977595c89f51ba6932366a755776" | gpg --dearmor -o /etc/apt/trusted.gpg.d/deadsnakes.gpg \
    && echo "deb [signed-by=/etc/apt/trusted.gpg.d/deadsnakes.gpg] https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/deadsnakes.list \
    # Docker PPA
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    # K8s PPA
    && curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-apt-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" > /etc/apt/sources.list.d/kubernetes.list \
    # Terraform PPA
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/trusted.gpg.d/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list

RUN set -eux \
    && apt-get update \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - \
    && apt-get install -y \
       vim fuse git zsh silversearcher-ag tmux docker-ce-cli htop libxml2-utils rsync \
       wget unzip inetutils-ping inetutils-traceroute inetutils-telnet dnsutils \
       python3.8 python3.8-distutils python3.8-dev python3.8-venv \
       python3.9 python3.9-distutils python3.9-dev python3.9-venv \
       python3.10 python3.10-distutils python3.10-dev python3.10-venv\
       python3.11 python3.11-distutils python3.11-dev python3.11-venv\
       python3.12 python3.12-distutils python3.12-dev python3.12-venv\
       python3-pip \
       nodejs \
       kubectl \
       terraform \
    && /usr/bin/env python3 -m pip install --upgrade pip \
    && /usr/bin/env python3 -m pip install docker-compose "Cython<3.0" --no-build-isolation \
    && npm install -g yarn \
    && rm -rf /root/.cache/pip \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=jsatt
ARG USER_HOME=/home/jsatt
ENV USERNAME=${USERNAME} USER_HOME=${USER_HOME}

RUN mkdir -p $USER_HOME \
    && useradd --home $USER_HOME --shell /usr/bin/zsh $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && adduser $USERNAME root

COPY entrypoint.sh /

USER ${USERNAME}
WORKDIR ${USER_HOME}

CMD '/entrypoint.sh'
