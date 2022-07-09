#!/bin/bash

# docker compose -f compose.rosbot.yaml -f compose.rosbot.vpn.yaml restart slam-toolbox
echo "resetting map ..."
docker restart slam-toolbox
echo "done"