#!/bin/bash

source $(dirname $0)/rl.env

# login
JSON=$(curl -s -d "[{\"cmd\":\"Login\",\"action\":0,\"param\":{\"rs\": \"abcd\", \"User\":{\"userName\":\"$USER\",\"password\":\"$PW\"}}}]" $HOST/api.cgi?cmd=Login)
TOKEN=$(echo $JSON | jq -r .[0].value.Token.name)

# fetch picture
wget -O $1 "http://$HOST/cgi-bin/api.cgi?cmd=Snap&channel=0&rs=YSkd_RRrShvyAMZv&token=$TOKEN"
