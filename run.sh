#!/bin/bash

#LEDE/Openwrt may need install ca-bundle curl(opkg install ca-bundle curl)

#Add you custom record to the CloudFlare first.

#Your sub domain
SUB_DOMAIN="sub.example.com"
#dash --> example.com --> Overview --> Zone ID:
#https://dash.cloudflare.com/_your_account_id_/example.com
ZONE_ID="5d41402abc4b2a76b9719d911017c592"
#API Tokens
#https://dash.cloudflare.com/profile/api-tokens
#Manage access and permissions for your accounts, sites, and products
#example.com- Zone:Read, DNS:Edit
TOKEN_ID="7d793037a076018657-_rZiSa4-f5xIgEvZzHNv"
#The path of jq binaries . Download from https://stedolan.github.io/jq/download/
#If the system has installed jq. Just typed jq.
#If you custom a special binary. Just type the path of jq
JQ_PATH="jq"

if [ -n "$DNS_ZONE_ID" ]; then
    echo "The user has not configure the the ZONE ID "
    exit 1
fi

echo "Your dns zone id is: $ZONE_ID"
jsonResult=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
    -H "Authorization: Bearer ${TOKEN_ID}" \
    -H "Content-Type: application/json")

curlResult=$(echo $jsonResult | $JQ_PATH -r .success)

if [ "$curlResult" = true ]; then
    echo "Get dns record success."
else
    echo "Get dns record fail.$jsonResult"
    exit 1
fi

recordSize=$(echo $jsonResult | $JQ_PATH .result | $JQ_PATH length)
echo "Total found $recordSize record"

index=0
while [ $index -lt $recordSize ]; do
    tResult=$(echo $jsonResult | $JQ_PATH -r .result[$index])
    tmpDomain=$(echo $tResult | $JQ_PATH -r .name)
    type=$(echo $tResult | $JQ_PATH -r .type)

    if [ "$tmpDomain"x = "$SUB_DOMAIN"x ]; then
        if [ "AAAA"x = "$type"x ]; then
            echo "Found AAAA domain:$tmpDomain"
            identifier_v6=$(echo $tResult | $JQ_PATH -r .id)
        elif [ "A"x = "$type"x ]; then
            echo "Found A domain:$tmpDomain"
            identifier_v4=$(echo $tResult | $JQ_PATH -r .id)
        else
            echo "Please add the A or AAAA record manually first."
        fi
    fi
    index=$(expr $index + 1)
done

if [ -z "$identifier_v4" ] && [ -z "$identifier_v6" ]; then
    echo "Get '$SUB_DOMAIN' identifier failed. Please add the A or AAAA record manually first."
    exit 1
else
    echo "Get '$SUB_DOMAIN' identifier success. [A] identifier:$identifier_v4 [AAAA] identifier:$identifier_v6"
fi

if [ -z "$identifier_v4" ]; then
    echo "IPv4 address are not required."
else
    #IP=$(curl -s http://members.3322.org/dyndns/getip)
    IP=$(curl -s https://api-ipv4.ip.sb/ip)
    regex='\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}\b'
    matchIP=$(echo $IP | grep -E $regex)
    if [ -n "$matchIP" ]; then
        echo "[$IP] IPv4 matches..."
        jsonResult=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${identifier_v4}" \
            -H "Authorization: Bearer ${TOKEN_ID}" \
            -H "Content-Type: application/json" \
            --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":1,"proxied":false}')
        curlResult=$(echo $jsonResult | $JQ_PATH -r .success)

        if [ "$curlResult" = true ]; then
            echo "Update IPv4 dns record success."
        else
            echo "Update IPv4 dns record fail."
        fi
    else
        echo "[$IP]IPv4 doesn't match!"
    fi
fi

if [ -z "$identifier_v6" ]; then
    echo "IPv6 addresses are not required."
else
    IP=$(curl -s https://api-ipv6.ip.sb/ip)
    regex='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'
    matchIP=$(echo $IP | grep -E $regex)
    if [ -n "$matchIP" ]; then
        echo "[$IP] IPv6 matches..."
        echo "Update IPv6 ..."
        jsonResult=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${identifier_v6}" \
            -H "Authorization: Bearer ${TOKEN_ID}" \
            -H "Content-Type: application/json" \
            --data '{"type":"AAAA","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":1,"proxied":false}')
        curlResult=$(echo $jsonResult | $JQ_PATH -r .success)

        if [ "$curlResult" = true ]; then
            echo "Update IPv6 dns record success."
        else
            echo "Update IPv6 dns record fail."
        fi
    else
        echo "[$IP] IPv6 doesn't match!"
    fi
fi
