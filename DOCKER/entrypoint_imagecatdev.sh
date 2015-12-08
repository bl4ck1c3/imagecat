#!/bin/bash
source $OODT_HOME/bin/imagecatenv.sh
cd $OODT_HOME/bin && ./oodt start
cd $OODT_HOME/tomcat7/bin && ./startup.sh
cd $OODT_HOME/resmgr/bin/ && ./start-memex-stubs


echo "Docker Container ID:" $HOSTNAME
pushd $OODT_HOME/logs/
python -m SimpleHTTPServer &

if [ -n "$IMAGECAT_IMAGE_PATH" ] && [ -d "$IMAGECAT_IMAGE_PATH" ]; then
    pushd $IMAGECAT_IMAGE_PATH
    python -m SimpleHTTPServer 9241 &
fi

$OODT_HOME/bin/chunker
INITIAL_CHUNK=$?

if [ $INITIAL_CHUNK -eq 0 ]; then
    echo "Watching /deploy/data/staging/roxy-image-list-jpg-nonzero.txt"
    while inotifywait -e close_write /deploy/data/staging/roxy-image-list-jpg-nonzero.txt; do $OODT_HOME/bin/chunker; done
else
    echo "Failed to run chunker"
    exit 1
fi
