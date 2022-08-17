#!/bin/bash

if [ $# -ne 2 ]; then
    echo ERROR: use exactly TWO arguments, eg: \"./generate-vpn-config.sh myrobot mylaptop\"
    exit 1
fi

OUTPUT_PATH="./"
DDS_FILE_NAME="dds-config.template.xml"

cp $DDS_FILE_NAME $OUTPUT_PATH/dds-config.xml

HOST1_IPV6=$(grep "\s$1\s#\smanaged\sby\sHusarnet" /etc/hosts | sed -r "s/(0-9a-f:)*\s($1)\s#\smanaged\sby\sHusarnet/\1/g")
HOST2_IPV6=$(grep "\s$2\s#\smanaged\sby\sHusarnet" /etc/hosts | sed -r "s/(0-9a-f:)*\s($2)\s#\smanaged\sby\sHusarnet/\1/g")

if [ -z "$HOST1_IPV6" ]
then
    echo "there is no \"$1\" host in /etc/hosts"
    exit 1
fi

if [ -z "$HOST2_IPV6" ]
then
    echo "there is no \"$2\" host in /etc/hosts"
    exit 1
fi

echo Husarnet IPv6 addr of $1 is: $HOST1_IPV6
echo Husarnet IPv6 addr of $2 is: $HOST2_IPV6

sed -i "s/replace-it-with-ipv6-addr-of-your-laptop/$HOST1_IPV6/g" $OUTPUT_PATH/dds-config.xml
sed -i "s/replace-it-with-ipv6-addr-of-your-rosbot/$HOST2_IPV6/g" $OUTPUT_PATH/dds-config.xml