#!/bin/bash
MAIN_SCR="eDP-1"
# Run xrandr and capture its output
XRANDR_OUTPUT=$(xrandr)
# get all the screens detected by the xrandr 
CONN_DISP_NAME=$(echo "$XRANDR_OUTPUT" | grep " connected ")
# from the detected screens get theire associated prot  
echo "[INFO]: Connected Display Ports:"
#echo "$CONN_DISP" | awk '{print $1}'
CONN_DISP_PORT=$(echo "$CONN_DISP_NAME" | awk '{print $1}')
echo $CONN_DISP_PORT
echo "************" 
# trasnform the CONN_DISP_PORT to an array called SCR_PORTS 
mapfile -t SCR_PORTS <<< "$CONN_DISP_PORT"
# loop through the array until it finds a new screen that is diffrent from the main screen {eDP-1}
# @TODO: 
# It will choose the first screen that the xrandr detected, so if you want to manage
# 3 screens you won't be able at the first time
# for example: set the screen you cannot unless it's detected first by xrandr  
for port in "${SCR_PORTS[@]}"
 do 
    if [ "$port" != $MAIN_SCR ]; then 
      echo "[INFO]: new screen detected ${port}"
      NEW_SCR=${port} 
	    break
    fi 
done  
# check if there is there is a connected screen
echo $NEW_SCR
if [[ -z $NEW_SCR ]]; then
  ERR_STR="No screen detected, Please make sure you have set properly your screen !!"
  echo "[ERROR]: ${ERR_STR}" 
  echo "[ERROR]: Nothing to do existing ..."
  notify-send -a  -c "error" "[ERROR]: No screen detected" -t 3000 # ${ERR_STR} -t  
  exit 1
fi 
# set's up the dmenu choices  
CHOICE=$(echo -e \
"Share screen Left
Share screen Right
Duplicate Screen
Disable Screen"\
| rofi -dmenu -p "Screen manager: ")

# Process the user's choice
case "$CHOICE" in
    "Share screen Left") 
        echo "[OPT-1]: SHARING SCREEN Left to MAIN screen."
        xrandr --output $NEW_SCR  --auto --left-of $MAIN_SCR
    ;;
    "Share screen Right") 
      echo "[OPT-2]: SHARING SCREEN Right to MAIN screen."
      xrandr --output $NEW_SCR  --auto --right-of $MAIN_SCR
    ;;
    "Duplicate Screen")
      echo "[OPT-3]: DUPLICATING screen"
      xrandr --output $NEW_SCR --auto --same-as $MAIN_SCR
    ;;
    "Disable Screen")
      echo "[OPT-4]: STOP SHARING screen."
 	    xrandr --output $NEW_SCR --off
    ;;
    *) 
      echo "[ERROR]: Invalid choice."; exit 1;;
esac

 
 #eDP-1

