#!/bin/bash

if [ $# -ne 1 ]; then
    echo ERROR: use exactly ONE arguments, eg: \"./generate-vpn-config.sh myrobot\"
    exit 1
fi

OUTPUT_PATH="./"
DDS_FILE_NAME_SERVER="dds-config.server.template.xml"
DDS_FILE_NAME_CLIENT="dds-config.client.template.xml"

cp $DDS_FILE_NAME_SERVER $OUTPUT_PATH/dds-config.server.xml
cp $DDS_FILE_NAME_CLIENT $OUTPUT_PATH/dds-config.client.xml

HOST_IPV6=$(grep "\s$1\s#\smanaged\sby\sHusarnet" /etc/hosts | sed -r "s/(0-9a-f:)*\s($1)\s#\smanaged\sby\sHusarnet/\1/g")

if [ -z "$HOST_IPV6" ]
then
    echo "there is no \"$1\" host in /etc/hosts"
    exit 1
fi

echo Husarnet IPv6 addr of $1 is: $HOST_IPV6

sed -i "s/replace-it-with-ipv6-addr-of-your-rosbot/$HOST_IPV6/g" $OUTPUT_PATH/dds-config.server.xml
sed -i "s/replace-it-with-ipv6-addr-of-your-rosbot/$HOST_IPV6/g" $OUTPUT_PATH/dds-config.client.xml