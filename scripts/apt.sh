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

pkg_name="$(apt-cache search ^"$q" | head -n 1 | cut -f1 -d' ' 2>/dev/null)"
if [[ -z "$pkg_name" ]]; then
	exit 0
fi
curl -sL "https://packages.ubuntu.com/focal/$pkg_name" | /home/syretia/.local/bin/pup 'meta json{}'
