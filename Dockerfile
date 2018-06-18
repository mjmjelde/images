# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Source Engine
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM        debian:stable-slim

MAINTAINER  Pterodactyl Software, <support@pterodactyl.io>
ENV         DEBIAN_FRONTEND noninteractive
# Install Dependencies
RUN         dpkg --add-architecture i386 \
            && apt-get update \
            && apt-get install -y bash wget curl libstdc++6:i386 \
            && useradd -m -d /home/container container

WORKDIR     /opt/steamcmd
RUN         curl -sSLO http://media.steampowered.com/installer/steamcmd_linux.tar.gz \
            && tar -zxvf steamcmd_linux.tar.gz -C /opt/steamcmd \
            && chown -R container:container /opt/steamcmd

USER        container
ENV         HOME /home/container
WORKDIR     /home/container

RUN         /opt/steamcmd/steamcmd.sh +login anonymous +quit

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]