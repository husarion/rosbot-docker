#!/bin/bash

# If your ROSbot's IP addr is 10.5.10.64 execute:
# ./sync_with_rosbot.sh 10.5.10.64

# If "bidirectional" flag is set, synchronize folders on PC and ROSbot using unison. Otherwise copy files with rsync
if [ "$2" == "--bidirectional" ]; then
    sshpass -p "husarion" unison -batch ./ ssh://husarion@$1/rosbot-docker-demo

    while inotifywait -r -e modify,create,delete,move ./ ; do 
        sshpass -p "husarion" unison -batch ./ ssh://husarion@$1/rosbot-docker-demo
    done
else
    sshpass -p "husarion" rsync -vRr ./ husarion@$1:/home/husarion/rosbot-docker-demo
fi

# The same but with rsync
# sshpass -p "husarion" rsync -vRr ./ husarion@$1:/home/husarion/rosbot-docker-demo

# while inotifywait -r -e modify,create,delete,move ./ ; do 
#     sshpass -p "husarion" rsync -vRr ./ husarion@$1:/home/husarion/rosbot-docker-demo
# done