FROM ubuntu:latest

RUN apt-get update && apt-get install -y locales locales-all apt-utils && rm -rf /var/lib/apt/lists/* \
    && yes | unminimize
#    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en

RUN set -eux \
    && apt-get update \
    && apt-get install -y sudo whois locales man-db apt-transport-https ca-certificates curl gnupg-agent software-properties-common \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository ppa:neovim-ppa/stable \
    && add-apt-repository ppa:git-core/ppa \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
    && curl -fsSL https://deb.nodesource.com/setup_12.x | sudo -E bash - \
    && apt-get install -y \
       neovim git zsh silversearcher-ag tmux docker-ce-cli htop ctags libxml2-utils rsync \
       inetutils-ping inetutils-traceroute inetutils-telnet dnsutils \
    && apt-get install -y \
       python3.7 python3.8 python3.8-dev python3-pip \
       nodejs yarn \
       libmysqlclient-dev \
       kubectl \
    && /usr/bin/env python3 -m pip install --upgrade pip \
    && /usr/bin/env python3 -m pip install \
        docker-compose \
    && rm -rf /root/.cache/pip \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*
# && curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
# && add-apt-repository "deb https://deb.nodesource.com/node_12.x/ $(lsb_release -cs) main" \

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
