#!/bin/bash

SRCROOT="$(pwd)/../src"
TARGETROOT="$(pwd)/../http"


find $SRCROOT -type f -print0 | while read -d '' -r file; do
    #remove src from filepath
    file=${file/$SRCROOT/}
    unset array
    #split remaining file path into array
    IFS='/' read -r -a array <<< "$file"
    FILEPATH=''
    DEPTH="../src/"
    unset array[0] #removes rogue directory seperator
    #loop through file path
    for element in "${array[@]}"
    do
        FILEPATH=$FILEPATH/$element
        TARGET=$TARGETROOT$FILEPATH
        SRC=$DEPTH$FILEPATH
        DEPTH=../$DEPTH
        if [ -L "${TARGET}" ]; then
          break
        fi
        #if target is a directory, continue loop
        if [ -d "${TARGET}" ]; then
            continue
        fi
        #if target is a file, remove it and symlink
        if [ -f "${TARGET}" ]; then
            if [ -L "${TARGET}" ]; then
              #it's a link, continue
              break
            fi
            #it's actually a file, remove it and symlinkg
            printf "|"
            #echo "removing and symlinking $FILEPATH"
            rm -f "${TARGET}"
            ln -s "${SRC}" "${TARGET}"
            break
        fi
        #echo $FILEPATH
        #if target doesn't exist, create symlink
        if [ ! -e "${TARGET}" ]; then
            printf "-"
            #echo "symlinking $FILEPATH"
            ln -s "${SRC}" "${TARGET}"
            break
        fi


    done
done

echo "done"
