FROM ubuntu:latest

RUN apt-get update && apt-get install -y locales locales-all apt-utils && rm -rf /var/lib/apt/lists/* \
    && yes | unminimize
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en
ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux \
    && apt-get update \
    && apt-get install -y sudo whois man-db apt-transport-https ca-certificates curl gnupg-agent software-properties-common \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/docker.gpg \
    && curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/kubernetes.gpg \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && add-apt-repository ppa:git-core/ppa \
    && add-apt-repository ppa:deadsnakes/ppa \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - \
    && apt-get install -y \
       vim fuse git zsh silversearcher-ag tmux docker-ce-cli htop libxml2-utils rsync \
       wget unzip inetutils-ping inetutils-traceroute inetutils-telnet dnsutils \
    && apt-get install -y \
       python3.8 python3.8-distutils python3.8-dev pythno3.8-venv \
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
