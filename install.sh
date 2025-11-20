#!/bin/sh
#
# install.sh
#
# This script handles the installation and uninstallation of the Sparky Server
# post-install scripts.
#
# Copyright (C) 2019 Paweł Pijanowski "pavroo" <pavroo@onet.eu>
# License: GNU GPL2
#

# --- Logic ---
# Check if the first command-line argument is "uninstall".
if [ "$1" = "uninstall" ]; then
    # --- Uninstallation ---
    # If the argument is "uninstall", remove the script and its data directory.
    rm -f /usr/bin/sparky-server
    rm -rf /usr/share/sparky/sparky-server
else
    # --- Installation ---
    # If no argument is provided, proceed with installation.
    # Copy the main script to the /usr/bin directory.
    cp bin/sparky-server /usr/bin/

    # Create the data directory if it doesn't already exist.
    if [ ! -d /usr/share/sparky/sparky-server ]; then
        mkdir -p /usr/share/sparky/sparky-server
    fi

    # Copy the localization files to the data directory.
    cp lang/* /usr/share/sparky/sparky-server/
fi
