#!/bin/sh

if [ -n "$SSH_PRIVATE_KEY" ]; then
    mkdir ~/.ssh/
    ssh-keyscan $REMOTE_GIT_HOST >> /tmp/hosts
    ssh-keygen -lf /tmp/hosts >> ~/.ssh/known_hosts
    rm /tmp/hosts
    cp $SSH_PRIVATE_KEY /tmp/key
    chmod 400 /tmp/key
    ssh-add /tmp/key
    rm /tmp/key
fi
mix phoenix.server 
