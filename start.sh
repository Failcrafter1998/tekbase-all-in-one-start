#!/bin/bash

# TekBase - server control panel
# Copyright since 2005 TekLab
# Christian Frankenstein
# Website: teklab.de
#          teklab.net

VAR_A=$1
VAR_B=$2
VAR_C=$3
VAR_D=$4
VAR_E=$5
VAR_F=$6
VAR_G=$7
VAR_H=$8
VAR_I=$9
VAR_J=${10}

DATADIR=$(pwd)

function gen_passwd { 
    PWCHARS=$1
    [ "$PWCHARS" = "" ] && PWCHARS=16
    tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${PWCHARS} | xargs
}

function sed_edit {
    SETFILE=$1
    SETVAR=$2
    SETVALUE=$3
    SETSEP=$4
    SETQUOTE=$5

    grep "${SETVAR}${SETSEP}" "${SETFILE}" &>/dev/null
    if [[ $? -eq 0 ]]; then
        sed -i "${SETFILE}" -e "s/^\(${SETVAR}${SETSEP}\).*$/\1${SETQUOTE}${SETVALUE}${SETQUOTE}/"
    else
        echo "${SETVAR}${SETSEP}${SETQUOTE}${SETVALUE}${SETQUOTE}" >> "${SETFILE}"
    fi
}


if [ "$VAR_A" = "arma3" ]; then
    # ./start.sh arma3 gsip gsport gsplayer

    if [ ! -d "../../.local/share/Arma 3" ]; then
        mkdir -p "../../.local/share/Arma 3"
    fi
    sed_edit "server.cfg" "maxPlayers" "${VAR_D}" "=" ""
    ./arma3server -server -netlog -ip="${VAR_B}" -port="${VAR_C}" -noSound -BEPath=battleye -config=server.cfg
fi


if [ "$VAR_A" = "ark" ]; then
	# ./start.sh ark gsport gsquerport gsplayer "TheIsland"
	
	# Adminpanel -> game list -> ark -> start folder -> "game" or "" but not "ShooterGame/Binaries/Linux" 
	SESSION_NAME=$(grep -i "SessionName" ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini | awk -F "=" '{print $2}')
	SERVER_PASSWORD=$(grep -i "ServerPassword" ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini | awk -F "=" '{print $2}')
	ADMIN_PASSWORD=$(grep -i "ServerAdminPassword" ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini | awk -F "=" '{print $2}')
	if [ "${SESSION_NAME}" = "" ]; then
		SESSION_NAME="Ark Server"
	fi
	if [ "${SERVER_PASSWORD}" = "" ]; then
		SERVER_PASSWORD="1q2w3e4r5t"
	fi
	if [ "${ADMIN_PASSWORD}" = "" ]; then
		ADMIN_PASSWORD=$(gen_passwd 8)
	fi
	echo "Hinweis: Der ARK Server braucht je nach Hardware 10-30 Minuten zum starten." > screenlog.0
	echo "Es tauchen einige Fehlermeldungen auf. Diese koennen ignoriert werden." >> screenlog.0
	echo "" >> screenlog.0	
	echo "Attention: The ARK server needs 10-30 minutes to start depending on the hardware." >> screenlog.0
	echo "Some error messages appear. These can be ignored." >> screenlog.0
	cd ShooterGame/Binaries/Linux/
	./ShooterGameServer "${VAR_E}"?listen?SessionName="${SESSION_NAME}"?ServerPassword="${SERVER_PASSWORD}"?ServerAdminPassword="${ADMIN_PASSWORD}"?Port="${VAR_B}"?QueryPort="${VAR_C}"?MaxPlayers="${VAR_D}" -server -log
fi


if [ "$VAR_A" = "minecraft" ]; then
    # ./start.sh minecraft gsip gsport gsplayer gsram "minecraft_server"

    # The fourth parameter is the separator. "=" or " "
    # The fifth parameter is the quote. "\"" or "'" or ""
    sed_edit "server.properties" "enable-query" "true" "=" ""
    sed_edit "server.properties" "server-ip" "${VAR_B}" "=" ""
    sed_edit "server.properties" "server-port" "${VAR_C}" "=" ""
    sed_edit "server.properties" "max-players" "${VAR_D}" "=" ""
    # You can add more changes here... VAR_G - VAR_J
    # Example START:
    if [ "${VAR_J}" != "" ]; then
        sed_edit "server.properties" "variable_xyz" "${VAR_G}" "=" ""
        sed_edit "server.properties" "variable_xyz" "${VAR_H}" "=" ""
        sed_edit "server.properties" "variable_xyz" "${VAR_I}" "=" ""
        sed_edit "server.properties" "variable_xyz" "${VAR_J}" "=" ""
    fi
    # Example END
    echo "eula=true" > eula.txt
    if [ "${VAR_F}" = "" ]; then
        VAR_F="minecraft_server"
    fi
    java -Xmx"${VAR_E}"M -Xms"${VAR_E}"M -jar "${VAR_F}".jar nogui "${VAR_B}" "${VAR_C}"
fi


if [ "$VAR_A" = "rust" ]; then
    # ./start.sh rust gsip gsport gsplayer

    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${DATADIR}/RustDedicated_Data/Plugins/x86_64
    export LD_LIBRARY_PATH
    let SETRCONPORT=${VAR_C}+1
    ./RustDedicated -batchmode -nographics +server.ip "${VAR_B}" +server.port "${VAR_C}" +rcon.ip "${VAR_B}" +rcon.port "${SETRCONPORT}" +rcon.web 0 +server.tickrate 66 +server.maxplayers "${VAR_D}" +server.worldsize 3000 +server.saveinterval 300 -logfile serverlog.txt
fi


if [ "$VAR_A" = "samp" ]; then
    # ./start.sh samp gsip gsport gsplayer

    sed_edit "server.cfg" "maxplayers" "${VAR_D}" " " ""
    sed_edit "server.cfg" "port" "${VAR_C}" " " ""   
    ./samp03svr -IP $1
fi


if [ "$VAR_A" = "shoutcast" ]; then
    ulimit -n 10000
    nohup sc_server
    ./sc_serv sc_serv.conf
fi

if [ "$VAR_A" = "theisle" ]; then
    # ./start.sh theisle gsport gsquerport gsplayer "survival"

    # Adminpanel -> game list -> theisle -> start folder -> "game" or "" but not "TheIsle/Binaries/Win64" 
    export WINEARCH=win64
    export WINEPREFIX=${DATADIR}/.wine64
    xvfb-run --auto-servernum  --server-args='-screen 0 640x480x24:32' wine TheIsle/Binaries/Win64/TheIsleServer-Win64-Shipping.exe /Game/TheIsle/Maps/Landscape3/Isle_V3?listen?game="${VAR_E}"?MaxPlayers="${VAR_D}"?port="${VAR_B}"?queryport="${VAR_C}"
fi


exit 0
