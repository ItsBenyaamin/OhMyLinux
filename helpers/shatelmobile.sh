#!/bin/bash

# First, login in https://my.shatelmobile.ir
# Then, Extract these two values from headers of /remained request
session="session=xxx"
msisdn='{"msisdn":"xxxx"}'

result=$(curl 'https://my.shatelmobile.ir/remained' \
    -H 'Accept: undefined' \
    -H 'Accept-Language: en-US,en;q=0.5' \
    -H 'Connection: keep-alive' \
    -H 'Content-Type: application/json' \
    -b "${session}; show_modal=False" \
    -H 'Origin: https://my.shatelmobile.ir' \
    -H 'Referer: https://my.shatelmobile.ir/' \
    -H 'Sec-Fetch-Dest: empty' \
    -H 'Sec-Fetch-Mode: cors' \
    -H 'Sec-Fetch-Site: same-origin' \
    -H 'Sec-GPC: 1' \
    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36' \
    -H 'X-Requested-With: XMLHttpRequest' \
    -H 'sec-ch-ua: "Not)A;Brand";v="8", "Chromium";v="138", "Brave";v="138"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Linux"' \
    --data-raw "${msisdn}")

{
    read -r remained
    read -r remained_unit
} < <(echo "$result" | jq -r '.internet_used, .internet_used_unit')
unit=""

if [[ "$remained" != "0.0" ]]; then
    if [[ "$remained_unit" == "گیگابایت" ]]; then
        unit="GB"
    else
        unit="MB"
    fi

    echo "$remained $unit"
else
    echo "-!!-"
fi
