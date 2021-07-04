#!/bin/sh

if [ -n "$SSH_PRIVATE_KEY" ]; then
    export GIT_SSH=/opt/app/ssh-helper
fi
mix phoenix.server 
