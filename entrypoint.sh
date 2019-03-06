#!/bin/bash
cd /home/container
sleep 1
# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Update Source Server
if [ ! -z ${APP_ID} ]; then
    if [ ! -z ${SRCDS_BETAID} ]; then
        if [ ! -z ${SRCDS_BETAPASS} ]; then
            ./steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} -beta ${SRCDS_BETAID} -betapassword ${SRCDS_BETAPASS} +quit
        else
            ./steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} -beta ${SRCDS_BETAID} +quit
        fi
    else
        ./steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${APP_ID} +quit
    fi
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP} |& tee latest.log
