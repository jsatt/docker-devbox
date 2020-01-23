FROM ubuntu:latest

RUN apt-get update && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN set -eux \
    && apt-get update \
    && apt-get install -y sudo whois locales apt-transport-https ca-certificates curl gnupg-agent software-properties-common \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - \
    && add-apt-repository ppa:jonathonf/vim \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && add-apt-repository "deb http://packages.cloud.google.com/apt cloud-sdk main" \
    && add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update \
    && apt-get install -y \
       vim git zsh silversearcher-ag tmux docker-ce-cli htop ctags libxml2-utils rsync \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update \
    && apt-get install -y \
       python3.7 python3-pip \
       node npm yarn \
       libmysqlclient-dev \
       kubectl google-cloud-sdk \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*
RUN /usr/bin/env python3 -m pip install --upgrade pip \
    && /usr/bin/env python3 -m pip install \
        gitchangelog bumpversion pystache \
    && rm -rf /root/.cache/pip

RUN useradd -m -s /usr/bin/zsh jsatt \
    && echo "jsatt ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && adduser jsatt root

COPY entrypoint.sh /

USER jsatt
WORKDIR /home/jsatt

CMD '/entrypoint.sh'
