#!/bin/bash

echo "# IP ranges for EC2"


IP_RANGE_DOC='https://forums.aws.amazon.com/ann.jspa?annID=1701'

SRC=https://ip-ranges.amazonaws.com/ip-ranges.json

CONTENT=$(curl -s https://ip-ranges.amazonaws.com/ip-ranges.json)
#echo $CONTENT

REGIONS=( ap-northeast-1  ap-southeast-1  ap-southeast-2  cn-north-1  eu-central-1  eu-west-1  sa-east-1  us-east-1  us-gov-west-1  us-west-1  us-west-2 )



dump_cidr () {
    region=$1

    echo $CONTENT   \
        | jq .prefixes | jq ".[] | select(.region==\"$region\")"  \
        | jq 'select(.service=="EC2")' | jq .ip_prefix            \
        | cut -d '"' -f 2
}


for i in ${REGIONS[@]}; do
    region=${i}

    echo
    echo "#  $region "
    dump_cidr $region | ./cidr-to-openvpn-route.pl

done