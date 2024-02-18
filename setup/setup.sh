#!/bin/bash

function setupGitHooks() {
    GIT_HOOKS_DIR=.git/hooks
    
    git config --local core.hooksPath $GIT_HOOKS_DIR
    
    rm $GIT_HOOKS_DIR/commit-msg*
    cp setup/files/commit-msg.sh $GIT_HOOKS_DIR/commit-msg
    chmod +x $GIT_HOOKS_DIR/commit-msg
}

function installDependencies() {
    sudo apt install -y meson valac libgtk-3-dev libgranite-dev libsecret-1-dev
}

echo "Setting up the dev environment for Alohomora..."
setupGitHooks
installDependencies
echo "Done!"

