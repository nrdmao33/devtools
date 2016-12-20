#!/usr/bin/bash

# Start up the vnc server.

cd
vncserver -geometry 1920x1200 -name $(uname -n) 
