#!/bin/sh

if [ -n "$SSH_PRIVATE_KEY" ]; then
    chmod 400 $SSH_PRIVATE_KEY
    ssh-add $SSH_PRIVATE_KEY
fi
mix phoenix.server $0