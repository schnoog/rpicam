#!/bin/bash

pic="/root/OWNTL/images/RAMTMP/newpic.jpg"


if [ -a "$pic" ]
then
echo "exists"
else
"not existing"
fi