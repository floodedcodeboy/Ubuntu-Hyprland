#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Main Hyprland Package #

hypr=(
  hyprland-protocols
  hyprwayland-scanner
)

# forcing to reinstall. Had experience it says hyprland is already installed
f_hypr=(
  hyprland
)
## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland.log"

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# force
printf "${NOTE} Installing Hyprland .......\n"
 for HYPR1 in "${f_hypr[@]}"; do
   re_install_package "$HYPR1" 2>&1 | tee -a "$LOG"
   [ $? -ne 0 ] && { echo -e "\e[1A\e[K${ERROR} - $HYPR1 Package installation failed, Please check the installation logs"; exit 1; }
done


# Hyprland
printf "${NOTE} Installing Hyprland .......\n"
 for HYPR in "${hypr[@]}"; do
   install_package "$HYPR" 2>&1 | tee -a "$LOG"
   [ $? -ne 0 ] && { echo -e "\e[1A\e[K${ERROR} - $HYPR Package installation failed, Please check the installation logs"; exit 1; }
done

clear 