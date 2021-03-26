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

# remove any files left behind in case process was killed by webhookd
for dir in $(ls /home/webhookd/runner/curl); do
    # break if nothing
    [[ -z "$dir" ]] && break
    # get date dir was created by removing random string at end
    dir_date="$(echo "$dir" | cut -f1 -d'_' | grep '[0-9]')"
    # check if is directory and dir_date variable is 10 chars long
    if [[ -d "/home/webhookd/runner/curl/$dir" && "${#dir_date}" -eq "10" ]]; then
        # delete if is dir and older than 10 seconds
        if [[ "$(($(date +%s)-$dir_date))" -gt "10" ]]; then
            rm -rf /home/webhookd/runner/curl/"$dir"
        fi
    # else remove any other junk left behind
    else
        rm -rf /home/webhookd/runner/curl/"$dir"
    fi
done

dir_name="$(date +%s)_$RANDOM"
mkdir -p /home/webhookd/runner/curl/"$dir_name"
cd /home/webhookd/runner/curl/"$dir_name"

raw_resp="$(curl -sLi "${url}" ${args} 2> /home/webhookd/runner/curl/"$dur_name"/curlstderr)"
resp_head="$(printf "%s\n" "$raw_resp" | awk '/^HTTP/,/^\r$/' | sed '/^\r$/d')"
resp_body="$(printf "%s\n" "$raw_resp" | awk '/^\r$/,/^$/' | sed '/^\r$/d')"
resp_stderr="$(cat /home/webhookd/runner/curl/"$dur_name"/curlstderr)"
jq -n --arg ul "$url" --arg ag "$args" --arg hd "$resp_head" --arg bd "$resp_body" --arg se "$resp_stderr" '{"url":$ul,"args":$ag,"head":$hd,"body":$bd,"stderr":$se}'
rm -rf /home/webhookd/runner/curl/"$dir_name"/*
