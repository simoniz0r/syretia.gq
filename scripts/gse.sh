#!/bin/bash

SEARCH_QUERY="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$q")"
SEARCH_RESULTS="$(curl -sL "https://www.google.com/search?q=$SEARCH_QUERY" \
-H 'User-Agent: Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Falkon/3.1.0 Chrome/69.0.3497.128 Safari/537.36' | \
pup 'a attr{href}' | \
grep '^http' | \
grep -v 'google' | \
perl -pe 'chomp if eof' | \
jq -c --raw-input --slurp 'split("\n")')"
TOP_RESULT="$(printf "%s\n" "$SEARCH_RESULTS" | jq -r '.[0]')"
SEARCH_META="$(curl -sL "$TOP_RESULT" | pup 'meta json{}')"
curl -sL "http://api.linkpreview.net/?key=86a22451d042b92ea493ae9a063448af&q=$TOP_RESULT" | jq ".meta |= $SEARCH_META" | jq ".results |= $SEARCH_RESULTS"
# META_LENGTH="$(printf "%s\n" "$SEARCH_META" | jq length)"
# META_LENGTH2="$((META_LENGTH+1))"
# printf "%s\n" "$SEARCH_META" | jq ".[$(echo $META_LENGTH)] |= {\"url\":\"$TOP_RESULT\"}" | jq ".[$(echo $META_LENGTH2)] |= {\"results\":$SEARCH_RESULTS}"
