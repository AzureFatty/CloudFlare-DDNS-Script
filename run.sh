#!/bin/bash

#LEDE/Openwrt may need install ca-bundle(opkg install ca-bundle)

#Your domain
DOMAIN="example.com"
#Your sub domain
SUB_DOMAIN="sub.example.com"
#Yor account
AUTH_EMAIL="Your account"
#Your auth key:https://www.cloudflare.com/a/profile --> Global API Key
AUTH_KEY="8b1a9953c4611296a827abf8c47804d7"
#The path of jq binaries . Download from https://stedolan.github.io/jq/download/ 
JQ_PATH="./jq-linux64"
#[Optional]https://www.cloudflare.com/a/overview/example.com --> Zone ID:
DNS_ZONE_ID="f5a7924e621e84c9280a9a27e1bcb7f6"

if [ -z "$DNS_ZONE_ID" ]; then
    jsonResult=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones" \
                         -H "X-Auth-Email: ${AUTH_EMAIL}" \
                         -H "X-Auth-Key: ${AUTH_KEY}" \
                         -H "Content-Type: application/json")
    curlResult=$(echo $jsonResult|$JQ_PATH -r .success)

    if [ "$curlResult" = true ]; then
        echo "Get domain list success."
    else
        echo "Get domain list fail."
        exit 1
    fi

    domainSize=$(echo $jsonResult | $JQ_PATH .result|$JQ_PATH length)
    echo "Total found $domainSize domain"

    index=0
    while [ $index -lt $domainSize ]; do
        tResult=$(echo $jsonResult | $JQ_PATH -r .result[$index])
        tmpDomain=$(echo $tResult | $JQ_PATH -r .name)
        echo "Found domain:$tmpDomain"
        if [ "$tmpDomain"x = "$DOMAIN"x ]; then
            DNS_ZONE_ID=$(echo $tResult | $JQ_PATH -r .id)
            break
        else
            echo 'not right'
        fi 
        index=`expr $index + 1`
    done
else
    echo "The user has set up ZONE ID "
fi


if [ -z "$DNS_ZONE_ID" ]; then
  echo "Get DNS ZONE ID  failed"
  exit 1
fi

echo "Your dns zone id is: $DNS_ZONE_ID"

jsonResult=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${DNS_ZONE_ID}/dns_records" \
                        -H "X-Auth-Email: ${AUTH_EMAIL}" \
                        -H "X-Auth-Key: ${AUTH_KEY}" \
                        -H "Content-Type: application/json")

curlResult=$(echo $jsonResult|$JQ_PATH -r .success)

if [ "$curlResult" = true ]; then
    echo "Get dns record success."
else
    echo "Get dns record fail.$jsonResult"
    exit 1
fi

recordSize=$(echo $jsonResult | $JQ_PATH .result|$JQ_PATH length)
echo "Total found $recordSize record"

index=0
while [ $index -lt $recordSize ]; do
    tResult=$(echo $jsonResult | $JQ_PATH -r .result[$index])
    tmpDomain=$(echo $tResult | $JQ_PATH -r .name)
    echo "Found domain:$tmpDomain"
    if [ "$tmpDomain"x = "$SUB_DOMAIN"x ]; then
        identifier=$(echo $tResult | $JQ_PATH -r .id)
        break
    fi
    index=`expr $index + 1`
done

if [ -z "$identifier" ]; then
    echo "Get '$SUB_DOMAIN' identifier failed."
    exit 1
else
    echo "Get '$SUB_DOMAIN' identifier success.identifier:$identifier"
fi

IP=$(curl -s http://members.3322.org/dyndns/getip)

VLIED_IP=false
VALID_CHECK=$(echo $IP|awk -F. '$1<=255&&$2<=255&&$3<=255&&$4<=255{print "yes"}')
    if echo $IP|grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$">/dev/null; then
        if [ "${VALID_CHECK:-no}"x = "yes"x ]; then
            echo "IP $IP available."
            VLIED_IP=true;
        else
            echo "IP $IP not available!"
            VLIED_IP=false;
        fi
    else
        echo "IP format error!"
        VLIED_IP=false;
    fi

if [ "$VLIED_IP" = false ]; then
    exit 1
fi

jsonResult=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${DNS_ZONE_ID}/dns_records/${identifier}" \
                        -H "X-Auth-Email: ${AUTH_EMAIL}" \
                        -H "X-Auth-Key: ${AUTH_KEY}" \
                        -H "Content-Type: application/json" \
                        --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":1,"proxied":false}')
curlResult=$(echo $jsonResult|$JQ_PATH -r .success)

if [ "$curlResult" = true ]; then
    echo "Update dns record success."
else
    echo "Update dns record fail."
    exit 1
fi
