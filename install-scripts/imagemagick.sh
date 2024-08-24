#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# ImageMagick from source #

# List of dependencies required for building
depend=(
    build-essential
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_image.log"
MLOG="install-$(date +%d-%H%M%S)_image2.log"

# Installing dependencies
for PKG1 in "${depend[@]}"; do
    install_package "$PKG1" 2>&1 | tee -a "$LOG"
    if [ $? -ne 0 ]; then
        echo -e "\033[1A\033[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
        exit 1
    fi
done

# Function to get the installed version of ImageMagick
get_installed_version() {
    apt show imagemagick 2>/dev/null | grep -i version | awk '{print $2}'
}

# Check if ImageMagick is installed
if dpkg -l | grep -qw imagemagick; then
    # Get the installed version of ImageMagick
    installed_version=$(get_installed_version)
    
    if [[ -z "$installed_version" ]]; then
        echo "Unable to determine the installed version of ImageMagick."  2>&1 | tee -a "$LOG"
        echo "Reinstalling ImageMagick from source..."  2>&1 | tee -a "$LOG"
    else
        # Extract the major and minor version numbers
        if [[ "$installed_version" =~ ^8:6\.9 ]]; then
            echo "ImageMagick version $installed_version is 8:6.9.* or less."  2>&1 | tee -a "$LOG"
            echo "Uninstalling installed $installed_version and installing from source" 2>&1 | tee -a "$LOG"
            
            sudo apt autoremove imagemagick 2>&1 | tee -a "$LOG"

        elif [[ "$installed_version" =~ ^8:7 ]]; then
            echo "ImageMagick version $installed_version is 8:7.* or higher."  2>&1 | tee -a "$LOG"
            echo "No action needed."  2>&1 | tee -a "$LOG"
            exit 0
        fi
    fi
else
    echo "ImageMagick is not installed."  2>&1 | tee -a "$LOG"
    echo "Installing ImageMagick from source..."  2>&1 | tee -a "$LOG"
fi

# Check if folder exists and remove it
if [ -d "ImageMagick" ]; then
    printf "${NOTE} Removing existing ImageMagick folder...\n"
    rm -rf "ImageMagick"
fi

# Clone and build ImageMagick
printf "${NOTE} Installing ImageMagick...\n"
if git clone --depth 1 https://github.com/ImageMagick/ImageMagick.git; then
    cd ImageMagick || exit 1
    ./configure
    make
    if sudo make install 2>&1 | tee -a "$MLOG"; then
        sudo ldconfig /usr/local/lib
        printf "${OK} ImageMagick installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for ImageMagick." 2>&1 | tee -a "$MLOG"
    fi
    # Moving the additional logs to Install-Logs directory
    mv "$MLOG" ../Install-Logs/ || true
    cd ..
else
    echo -e "${ERROR} Download failed for ImageMagick." 2>&1 | tee -a "$LOG"
fi

clear
