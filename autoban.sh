#!/bin/bash

# Enter your IP address here, otherwise you may accidently ban yourself.
EXCLUDEDIP=""

# Used to parse your nginx access log for specific key words to ban
# Typically a lot of bots will try to probe your webserver for your git or .env file
# so it makes it easier to IP ban them.

awk -F' ' '/"GET \/\.git|\.env HTTP\/1\.1" 400/{ print $1 | "sort -u" }' /var/log/nginx/access.log > bannedip.txt
awk -F' ' '/"GET \/\.git|\.env HTTP\/1\.1" 404/{ print $1 | "sort -u" }' /var/log/nginx/access.log >> bannedip.txt

# For really paranoid people, comment out the above.
# awk -F' ' '/"GET \/[^"]+ HTTP\/1\.1" 404|400/{ print $1 | "sort -u" }' /var/log/nginx/access.log > bannedip.txt

BANNABLEIP=$( <bannedip.txt )

IFS=$'\n' read -d '' -r -a BANNABLEIP_ARRAY <<< "$BANNABLEIP"

for ip in "${BANNABLEIP_ARRAY[@]}"; do
        if [[ "$ip" == "$EXCLUDEDIP" ]]; then
                echo "$ip excluded from banning." >> ufw_autoban_log.txt
        else
                checkip=$(sudo ufw status | grep "$ip")

                if [[ -n "$checkip" ]]; then
                        echo "'$ip' already in firewall!" >> ufw_autoban_log.txt
                else
                        echo "Added '$ip' to ufw firewall." >> ufw_autoban_log.txt
                        sudo ufw prepend deny from "$ip" # This will prepend all denies to the top of your firewall
        fi
done

