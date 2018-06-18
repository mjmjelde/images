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
            && apt-get install -y wget curl libstdc++6:i386 \
            && useradd -m -d /home/container container

USER        container
ENV         HOME /home/container
WORKDIR     /home/container

RUN         curl -sSLO http://media.steampowered.com/installer/steamcmd_linux.tar.gz \
            && mkdir steamcmd \
            && tar -zxvf steamcmd_linux.tar.gz -C ./steamcmd \
            && ./steamcmd/steamcmd.sh +login anonymous +quit

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]