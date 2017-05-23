#!/bin/sh

if [ -n "$SSH_PRIVATE_KEY" ]; then
    mkdir ~/.ssh/
    ssh-keyscan $REMOTE_GIT_HOST >> ~/.ssh/known_hosts
    cp $SSH_PRIVATE_KEY /tmp/key
    chmod 400 /tmp/key
    ssh-add /tmp/key
    rm /tmp/key
fi
mix phoenix.server 