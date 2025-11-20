# Sparky Server Post-Install

This repository provides a set of shell scripts to automate the post-installation
setup of all Sparky Server editions.

## Description

The `sparky-server` script simplifies the setup of a Sparky Server by launching
an installer that guides the user through the configuration process. The script
is localized and supports multiple languages.

## File Structure

- `bin/sparky-server`: The main executable script that launches the installer.
- `lang/`: A directory containing localization files for the script.
- `install.sh`: A script to install or uninstall the `sparky-server` tool.
- `README.md`: This file.

## Dependencies

- `apt`
- `bash`
- `coreutils`
- `dialog`
- `grep`
- `sparky-ad-server`

## Installation

To install the `sparky-server` script, run the following commands:

```bash
sudo ./install.sh
```

This will copy the necessary files to `/usr/bin` and `/usr/share/sparky`.

## Usage

After installation, you can run the script by typing:

```bash
sparky-server
```

The script will guide you through the post-installation setup process.

## Uninstallation

To uninstall the `sparky-server` script, run:

```bash
sudo ./install.sh uninstall
```

## License

This program is free software and is distributed under the GNU General Public
License v3. See the `LICENSE` file for more details.
