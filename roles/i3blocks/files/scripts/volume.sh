#!/usr/bin/env bash

focus_pavucontrol() {
  PROCESS_COUNT=`ps aux | grep -c pavucontrol`
  if [ $PROCESS_COUNT -eq 1 ]; then
    i3-msg exec pavucontrol > /dev/null
  else
    i3-msg "[class=Pavucontrol] focus" > /dev/null
  fi
}

case $BLOCK_BUTTON in
  1) focus_pavucontrol ;;
  3) amixer -q -D pulse sset Master toggle ;;
  4) amixer -q -D pulse sset Master 5%+ unmute ;;
  5) amixer -q -D pulse sset Master 5%- unmute ;;
esac

RAW_VOLUME=$(amixer -D pulse get Master | awk -F'[][]' '/\[[[:digit:]]{1,3}\%\]/ { print $2 ";" $4; exit; }')
IFS=';' read -r -a VOLUME <<< "$RAW_VOLUME"

if [ ${VOLUME[1]} = "off" ]; then
  echo ""
else
  PERCENT=${VOLUME[0]%?}
  if [ $PERCENT -lt 33 ]; then
    echo "" ${VOLUME[0]}
  elif [ $PERCENT -lt 66 ]; then
    echo "" ${VOLUME[0]}
  else
    echo "" ${VOLUME[0]}
  fi
fi
