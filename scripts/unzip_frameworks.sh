#!/bin/sh
cd SeeScoreLib || (echo "Unable to chdir to 'SeeScoreLib'"; exit 1)
(cd AppStore-Release && unzip -oq SeeScoreLib.framework.zip) || (echo "Unable to unzip release frameowrk"; exit 1)
(cd Universal && unzip -oq SeeScoreLib.framework.zip) || (echo "Unable to unzip universal frameowrk"; exit 1)
