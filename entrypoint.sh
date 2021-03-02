#!/bin/bash
cd /home/container
sleep 1
# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
    echo -e "steam user is not set.\n"
    echo -e "Using anonymous user.\n"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "user set to ${STEAM_USER}"
fi

## if auto_update is not set or to 1 update
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then 
    # Update Source Server
    if [ ! -z ${SRCDS_APPID} ]; then
        ./steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH}  +force_install_dir /home/container +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) $( [[ -z ${HLDS_GAME} ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) $( [[ -z ${VALIDATE} ]] || printf %s "validate" ) +quit
    else
        echo -e "No appid set. Starting Server"
    fi
    
    echo -e "Updating ValheimPlus"
    # Download ValheimPlus | curl -s https://api.github.com/repos/valheimPlus/ValheimPlus/releases/latest | jq '.assets[] | select(.name == "UnixServer.tar.gz") | .browser_download_url' -r | wget -O UnixServer.tar.gz -i -
    IGNORE_DIR=""
    if [-f /home/container/BepInEx/config/valheim_plug.cfg ]; then
      echo -e "Previous install found.  Adding exclude option for configuration files"
      IGNORE_DIR="--exclude=""/BepinEx/config"""
    fi
    
    curl -s https://api.github.com/repos/valheimPlus/ValheimPlus/releases/latest | jq '.assets[] | select(.name == "UnixServer.tar.gz") | .browser_download_url' -r | wget -O UnixServer.tar.gz -i -
    tar zxf UnixServer.tar.gz ${IGNORE_DIR}
    rm UnixServer.tar.gz
else
    echo -e "Not updating game server as auto update was set to 0. Starting Server"
fi

# ValheimPlus variables
export DOORSTOP_ENABLE=TRUE
export DOORSTOP_INVOKE_DLL_PATH=./BepInEx/core/BepInEx.Preloader.dll
export DOORSTOP_CORLIB_OVERRIDE_PATH=./unstripped_corlib

export LD_LIBRARY_PATH=./doorstop_libs:$LD_LIBRARY_PATH
export LD_PRELOAD=libdoorstop_x64.so:$LD_PRELOAD

export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=892970

# Replace Startup Variables
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
