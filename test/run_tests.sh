#!/bin/bash
set -e

# === Test Suite for Sparky Server ===
export HOME=/tmp

# --- Test Case 1: install.sh ---
run_install_tests() {
    echo "--- Running tests for install.sh ---"
    # Setup test directory in a subshell to isolate environment
    (
        set -e
        INSTALL_TEST_DIR=$(mktemp -d)
        trap 'sudo rm -rf -- "$INSTALL_TEST_DIR" /usr/bin/sparky-server /usr/share/sparky' EXIT

        cd "$INSTALL_TEST_DIR"

        mkdir -p bin
        touch bin/sparky-server
        mkdir -p lang
        touch lang/en

        cp "$OLDPWD/install.sh" .

        echo "Testing installation..."
        sudo ./install.sh
        if [ ! -f /usr/bin/sparky-server ]; then
            echo "Installation test failed: sparky-server not found in /usr/bin"
            exit 1
        fi
        if [ ! -f /usr/share/sparky/sparky-server/en ]; then
            echo "Installation test failed: language file not found in /usr/share/sparky/sparky-server"
            exit 1
        fi
        echo "Installation test passed."

        echo "Testing uninstallation..."
        sudo ./install.sh uninstall
        if [ -f /usr/bin/sparky-server ]; then
            echo "Uninstallation test failed: sparky-server still exists in /usr/bin"
            exit 1
        fi
        if [ -d /usr/share/sparky/sparky-server ]; then
            echo "Uninstallation test failed: /usr/share/sparky/sparky-server directory still exists"
            exit 1
        fi
        echo "Uninstallation test passed."
    )
}

# --- Test Case 2: sparky-server ---
run_server_tests() {
    echo "--- Running tests for sparky-server ---"
    # Setup test directory in a subshell to isolate environment
    (
        set -e
        SERVER_TEST_DIR=$(mktemp -d)
        trap 'rm -rf -- "$SERVER_TEST_DIR"' EXIT

        cd "$SERVER_TEST_DIR"

        mkdir -p bin
        cp "$OLDPWD/bin/sparky-server" bin/sparky-server
        chmod +x bin/sparky-server

        sed -i 's|DEFLOCDIR="/usr/share/sparky/sparky-server"|DEFLOCDIR="${DEFLOCDIR:-/usr/share/sparky/sparky-server}"|' bin/sparky-server
        sed -i 's|/etc/default/locale|./etc/default/locale|' bin/sparky-server
        sed -i 's|/usr/bin/sparky-ad-server|sparky-ad-server|' bin/sparky-server

        # Copy the original lang files
        mkdir -p lang
        cp $OLDPWD/lang/* lang/

        export DEFLOCDIR=$(pwd)/lang

        mkdir -p mocks
        echo -e '#!/bin/sh\necho "testuser"' > mocks/whoami
        chmod +x mocks/whoami
        echo -e '#!/bin/sh\necho "dialog called with: $*" >&2; exit 0' > mocks/dialog
        chmod +x mocks/dialog
        echo -e '#!/bin/sh\necho "sparky-ad-server called"' > mocks/sparky-ad-server
        chmod +x mocks/sparky-ad-server
        echo -e '#!/bin/sh\necho "apt-get called with: $*"' > mocks/apt-get
        chmod +x mocks/apt-get
        export PATH=$(pwd)/mocks:$PATH

        echo "Testing non-root execution..."
        output=$(./bin/sparky-server || true)
        expected="Must be root ... Exiting now ..."
        if [[ "$output" != "$expected"* ]]; then
            echo "Non-root test failed."
            echo "Expected: $expected"
            echo "Got: $output"
            exit 1
        fi
        echo "Non-root execution test passed."

        echo "Testing localization..."
        mkdir -p etc/default
        echo "LANG=de_DE.UTF-8" > etc/default/locale
        output=$(./bin/sparky-server || true)
        expected="Muss root sein ... Beende... ..."
        if [[ "$output" != "$expected"* ]]; then
            echo "Localization test failed."
            echo "Expected: $expected"
            echo "Got: $output"
            exit 1
        fi
        echo "Localization test passed."
        rm -rf etc

        echo "Testing root execution..."
        echo -e '#!/bin/sh\necho "root"' > mocks/whoami
        output=$(./bin/sparky-server 2>&1)
        if [[ "$output" != *"sparky-ad-server called"* ]]; then
            echo "Root execution (ad-server) test failed. Output: $output"
            exit 1
        fi
        if [[ "$output" != *"dialog called"* ]]; then
            echo "Root execution (dialog) test failed. Output: $output"
            exit 1
        fi
        if [[ "$output" != *"apt-get called with: purge sparky-server sparky-ad-server -y"* ]]; then
            echo "Root execution (purge) test failed. Output: $output"
            exit 1
        fi
        echo "Root execution test passed."

        echo "Testing root execution (no purge)..."
        echo -e '#!/bin/sh\necho "dialog called with: $*" >&2; exit 1' > mocks/dialog
        output=$(./bin/sparky-server 2>&1 || true)
        if [[ "$output" == *"apt-get called"* ]]; then
            echo "Root execution (no purge) test failed. apt-get was called. Output: $output"
            exit 1
        fi
        echo "Root execution (no purge) test passed."
    )
}

run_install_tests
run_server_tests

echo "All tests passed."
