FROM debian:squeeze

MAINTAINER Simon Hookway <simon@obsidian.com.au>

ENV DEBIAN_FRONTEND noninteractive

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG TIMEZONE
ARG DF_VOLUMES
ARG DF_PORTS
ARG REALM
ARG MACHINE
ARG SCRIPTARGS

ENV http_proxy ${HTTP_PROXY:-}
ENV https_proxy ${HTTPS_PROXY:-}

COPY jet-conf/obsidian.list /etc/apt/sources.list.d/
COPY jet-conf/debian.list /etc/apt/sources.list
COPY skel/.bashrc /root/
COPY skel/.vimrc /root/
COPY skel/.screenrc /root/

RUN mkdir /root/eggs && mkdir /root/bin
COPY eggs/ /root/eggs/

# Create the jet user before install the `jet` package so we control the UID
ENV HOME /home/jet
RUN useradd --create-home --home-dir $HOME --shell /bin/bash --uid 1001 jet

RUN apt-get clean \
  && apt-get update \
  && apt-get install --yes --force-yes libc6=2.11.3-4 libc6-dev=2.11.3-4 libc-bin=2.11.3-4 net-tools \
  && apt-get install --yes --force-yes --no-install-recommends libc-dev libmysqlclient-dev zlib1g-dev libtool python2.6-dev wget vim acl jet \
  && apt-get install --yes openssh-client openssh-server sshpass \
  && easy-install $HOME/eggs/elementtree-1.2.7-20070827-preview.zip \
  && easy-install $HOME/eggs/python-openid-1.2.0.zip \
  && easy-install $HOME/eggs/python-urljr-1.0.1.tar.gz \
  && easy-install $HOME/eggs/python-yadis-1.1.0.tar.gz \
  && easy-install $HOME/eggs/AuthKit-0.4.0.tar.gz \
  && easy-install pexpect

# configure sshd to not allow root login
RUN sed -i 's/^PermitRootLogin/# PermitRootlogin/' /etc/ssh/sshd_config

# Fix timezone
RUN rm /etc/localtime \
  && ln -sv /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  && dpkg-reconfigure -f noninteractive tzdata

COPY skel/ $HOME/
COPY clients/$REALM/id_rsa $HOME/.ssh/
RUN chown jet:jet -R $HOME && chmod 700 $HOME/.ssh && chmod 600 $HOME/.ssh/id_rsa && chmod 755 $HOME/bin/*

STOPSIGNAL SIGTERM

VOLUME $DF_VOLUMES
EXPOSE $DF_PORTS

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD [""]

