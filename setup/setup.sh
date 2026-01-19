#!/bin/bash

function setupGitHooks() {
    GIT_HOOKS_DIR=.git/hooks
    
    git config --local core.hooksPath $GIT_HOOKS_DIR
    
    rm $GIT_HOOKS_DIR/commit-msg*
    cp setup/files/commit-msg.sh $GIT_HOOKS_DIR/commit-msg
    chmod +x $GIT_HOOKS_DIR/commit-msg
}

function installDependencies() {
    sudo apt install -y meson valac libgtk-4-dev libgranite-7-dev libsecret-1-dev
}

echo "Setting up the dev environment for Alohomora..."
setupGitHooks
installDependencies
echo "Done!"
