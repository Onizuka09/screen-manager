#!/bin/bash
MAIN_SCR="eDP-1"

XRANDR_CMD="xrandr"
WAYLAND_CMD=""

MAPFILE_CMD="mapfile"
# Check which Display server you are using ( Wayland or Xorg )
[[ $XDG_SESSION_TYPE == "x11" ]] && {
  echo "Running on Xorg"
  CMD=${XRANDR_CMD}
  } || {
    echo " Running on wayland " 
    echo "Not supported for now "
    echo "Exiting ..."
    exit 1
  }


#Check if CMD exists
[[ ! $(command -v ${CMD}  &> /dev/null )  ]] && {
    # Run CMD and capture its output
    CMD_OUTPUT=$(${CMD}) 
    echo "xrandr installed ..."
  } || {
    echo "${CMD} not installed, Please installed :)"
    echo "exiting ..."
    exit 1
  }

# get all the screens detected by the xrandr 
CONN_DISP_NAME=$(echo "${CMD_OUTPUT}" | grep " connected ")
# from the detected screens get theire associated prot  
echo "[INFO]: Connected Display Ports:"
#echo "$CONN_DISP" | awk '{print $1}'
CONN_DISP_PORT=$(echo "${CONN_DISP_NAME}" | awk '{print $1}')
echo ${CONN_DISP_PORT}
echo "************" 
# check if mapfile command exist
if  command -v ${MAPFILE_CMD} &> /dev/null
then  
  # trasnform the CONN_DISP_PORT to an array called SCR_PORTS 
  ${MAPFILE_CMD} -t SCR_PORTS <<< "${CONN_DISP_PORT}"
  echo $MAIN_SCR
else 
  echo "${MAPFILE_CMD} isn't installed in your system"
  echo "please installed !" 
  echo "exiting ..."
  exit 1
fi
# loop through the array until it finds a new screen that is diffrent from the main screen {eDP-1}
# @TODO: 
# It will choose the first screen that the xrandr detected, so if you want to manage
# 3 screens you won't be able at the first time
# for example: set the screen you cannot unless it's detected first by xrandr  
for port in "${SCR_PORTS[@]}"
 do 
    if [ "${port}" != ${MAIN_SCR} ]; then 
      echo "[INFO]: new screen detected ${port}"
      NEW_SCR=${port} 
	    break
    fi 
done  
# check if there is there is a connected screen
echo ${NEW_SCR}
if [[ -z ${NEW_SCR} ]]; then
  ERR_STR="No screen detected, Please make sure you have set properly your screen !!"
  echo "[ERROR]: ${ERR_STR}" 
  echo "[ERROR]: Nothing to do existing ..."
  notify-send -a  -c "error" "[ERROR]: No screen detected" -t 3000 # ${ERR_STR} -t  
  exit 1
fi 
# Dict of choices
declar -A SCREEN_CHOICES=(
["Share Screen Left"]="--left-of"
["Share Screen Right"] ="--right-of"
["Duplicate Screen"]="--same-as"
)
XRANDR_CMD="xrandr --output"
# set's up the dmenu choices  
CHOICE=$(echo -e \
"Share screen Left
Share screen Right
Duplicate Screen
Disable Screen"\
| rofi -dmenu -p "Screen manager: ")

# Process the user's choice
CHOICE=${SCREEN_CHOICES[${CHOICE}]}

[[ "${CHOICE}" == "--off" ]] && 
  ${XRANDR_CMD} --off
||
  ${XRANDR_CMD} --outo ${CHOICE} ${MAIN_SCR}

