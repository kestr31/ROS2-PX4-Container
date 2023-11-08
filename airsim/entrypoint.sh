#! /bin/bash

debug_message() {
    echo "\033[35m
        ____  __________  __  ________   __  _______  ____  ______
       / __ \/ ____/ __ )/ / / / ____/  /  |/  / __ \/ __ \/ ____/
      / / / / __/ / __  / / / / / __   / /|_/ / / / / / / / __/   
     / /_/ / /___/ /_/ / /_/ / /_/ /  / /  / / /_/ / /_/ / /___   
    /_____/_____/_____/\____/\____/  /_/  /_/\____/_____/_____/   
    
    "
    echo -e "\033[35mINFO\t[ROS2-AIRSIM]\tDEBUG_MODE IS SET. NOTHING WILL RUN"
}

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
        # COMMENT_BASH_START=$(($COMMENT_BASH_START + 1))

        # #- WTIE VARIABLED TO BE EXPORTED TO THE TEMPFILE
        # echo "YOUR_VAR=0" >> /tmp/envvar

        # #- ADD VARIABLES TO BE EXPORTED TO SHELL RC
        # for value in $(cat /tmp/envvar)
        # do
        #     echo ${value} >> /home/user/.bashrc
        # done

        # #- ADD export STATEMENT TO VARIABLES
        # sed -i "${COMMENT_BASH_START},\$s/\(.*\)/export \1/g" \
        #     ${HOME}/.bashrc

        # #- REMOVE TEMPORARY FILE
        # rm -f /tmp/envvar

        echo -e "\033[32mINFO\t[ROS2-AIRSIM]\tNO ENVIRONMENT VARS TO BE SET"

    ### CASE A-1-2: NO LEAVE THEM CLEAN
    else
        echo -e "\033[31mINFO\t[ROS2-AIRSIM]\tENVIRONMENT VARS WILL NOT BE SET"
    fi


## CASE A-2: SIMULATION MODE
else

    # PLACE YOUR AUTSTART SCRIPT HERE
    echo -e "\033[32mINFO\t[ROS2-AIRSIM] NOTHING TO RUN. AT LEAST FOR NOW."

fi

# KEEP CONTAINER ALIVE
sleep infinity