#!/bin/bash

# convert key input to sha256sum
key_hash="$(printf "%s\n" "$key" | sha256sum | cut -f1 -d' ')"
# unset key input so cannot be seen by running script
unset key
# compare input key hash to stored key hash
case "$key_hash" in
    "$WHD_AUTH_HASH")
        # successful authorization
        sleep 0
        ;;
    *)
        # failed authorization
        echo '{"error":"Invalid authorization."}' | jq '.'
        exit
        ;;
esac
# create directory for current instance
dir_name="$(date +%s)_$RANDOM"
mkdir -p /home/webhookd/runner/"$dir_name"
printf "%s\n" "curl -sL $url | /home/syretia/.local/bin/pup '$path'" > /home/webhookd/runner/"$dir_name"/pup
source /home/webhookd/runner/"$dir_name"/pup
rm -rf /home/webhookd/runner/"$dir_name"
