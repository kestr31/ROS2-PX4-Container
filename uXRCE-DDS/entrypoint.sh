#! /bin/bash

debug_message() {
    echo "
        ____  __________  __  ________   __  _______  ____  ______
       / __ \/ ____/ __ )/ / / / ____/  /  |/  / __ \/ __ \/ ____/
      / / / / __/ / __  / / / / / __   / /|_/ / / / / / / / __/   
     / /_/ / /___/ /_/ / /_/ / /_/ /  / /  / / /_/ / /_/ / /___   
    /_____/_____/_____/\____/\____/  /_/  /_/\____/_____/_____/   
    
    "
    echo "INFO [SITL] DEBUG_MODE IS SET. NOTHING WILL RUN"
}


echo -e "INTO\t[XRCE] STARTING uXRCE AGENT..."
source /opt/ros/humble/setup.bash \
    && source ${HOME}/px4_ros_ws/install/setup.bash \
    && MicroXRCEAgent udp4 -p 8888


# A. DEBUG MODE / SIMULATION SELCTOR
## CASE A-1: DEBUG MODE
if [ "${DEBUG_MODE}" -eq "1" ]; then

    debug_message

    ## A-1. EXPORT ENVIRONMENT VARIABLE?
    ### CASE A-1-1: YES EXPORT THEM
    if [ "${EXPORT_ENV}" -eq "1" ]; then

        # PLACE YOUR ENVIRONMENT VARIABLE TO BE SET HERE
        # # - GET LINE NUMBER TO START ADDING export STATEMENT
        # COMMENT_BASH_START=$(grep -c "" /home/user/.bashrc)
        # COMMENT_ZSH_START=$(grep -c "" /home/user/.zshrc)

        # COMMENT_BASH_START=$(($COMMENT_BASH_START + 1))
        # COMMENT_ZSH_START=$(($COMMENT_ZSH_START + 1))


        # #- WTIE VARIABLED TO BE EXPORTED TO THE TEMPFILE
        # echo "DEBUG_MODE=0" >> /tmp/envvar
        # echo "GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}" >> /tmp/envvar

        # #- ADD VARIABLES TO BE EXPORTED TO SHELL RC
        # for value in $(cat /tmp/envvar)
        # do
        #     echo ${value} >> /home/user/.bashrc
        #     echo ${value} >> /home/user/.zshrc
        # done

        # #- ADD export STATEMENT TO VARIABLES
        # sed -i "${COMMENT_BASH_START},\$s/\(.*\)/export \1/g" \
        #     ${HOME}/.bashrc
        # sed -i "${COMMENT_ZSH_START},\$s/\(.*\)/export \1/g" \
        #     ${HOME}/.zshrc

        # #- REMOVE TEMPORARY FILE
        # rm -f /tmp/envvar

        echo "INFO [SITL] NO ENVIRONMENT VRIABLE TO BE SET"

    ### CASE A-1-2: NO LEAVE THEM CLEAN
    else
        echo "INFO [SITL] ENVIRONMENT VARS WILL NOT BE SET"
    fi


## CASE A-2: SIMULATION MODE
else

    # PLACE YOUR AUTSTART SCRIPT HERE
    echo "NOTHING TO RUN. AT LEAST FOR NOW."

fi

# KEEP CONTAINER ALIVE
sleep infinity