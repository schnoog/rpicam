#!/bin/bash

BASEDIR=$(dirname $(realpath $0))"/"
export PICDIR="$BASEDIR""images/"
INCDIR="$BASEDIR""inc"
export RAMDIR="$PICDIR""RAMTMP"
export LOGFILE="$RAMDIR""/app.log"

allincs=$(find "$INCDIR" -name '*.sh')
for inc in $allincs
do
source "$inc"
done

######################
##
## INI
#
#
CreateTMP

######################
##
## Functions (not all)
#
#
# TakeCroppedSizedPhoto "SavePath" %CamResolution 42 76 20 23
#  -> Takes a cam shot (adjusted ISO, EX, and AWB so brightness) with x% of the Cams resolution
#  --> Crops an image With 42% With, 76% Heigth, 20% Left Offset, 23% Top Offset
#
##
##
#
#
##
## TakeCroppedSizedPhotoFromGlobals "SavePath" "CamPercentage"
#
######################


##pic="$PICDIR""test.jpg"
##rm "$pic" 2>/dev/null


#TakeCroppedSizedPhotoFromGlobals "$pic" 50

#CompareSnapShots 
#SnapImage


PICNUM=$(GetFirstFreeTLNum)
GetCamBrightness

GetISO 1
GetEX 1














START=1
while [ $START -lt 100000 ]
do

MAKESNAPSHOT=0

NOW=$(date)
NOWTS=$(date +%s)

echo "---Frame---"$START"-----"$NOW
SNAPCOMPARE=$(CompareSnapShots)

if [ $SNAPCOMPARE -gt 0 ]
then  
echo "EVENT----PICTURE $NOW --- $SNAPCOMPARE" >> "$LOGFILE"
MAKESNAPSHOT=1
fi

TRIGGERSTRING=$NOWTS"%"$TIMELAPSESLEEP
TRIGGER=$(echo "$TRIGGERSTRING" | bc)

if [ $TRIGGER -eq 20 ]
then  
echo "TIMELAPE-PICTURE $NOW --- $SNAPCOMPARE" >> "$LOGFILE"
MAKESNAPSHOT=1
fi

if [ $MAKESNAPSHOT -eq 1 ]
then
picname="$PICDIR""$PICNUM"".jpg"
TakeCroppedSizedPhotoFromGlobals "$picname" $FULL_IMAGE_PERCENTAGE

let PICNUM=$PICNUM+1
fi



let START=$START+1

done 
















