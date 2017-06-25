#!/bin/sh

if [ -n "$SSH_PRIVATE_KEY" ]; then
    mkdir ~/.ssh/
    ssh-keyscan -p $REMOTE_GIT_PORT $REMOTE_GIT_HOST  >> ~/.ssh/known_hosts
    rm /tmp/hosts
    cp $SSH_PRIVATE_KEY /tmp/key
    chmod 400 /tmp/key
    ssh-add /tmp/key
    rm /tmp/key
fi
mix phoenix.server 
