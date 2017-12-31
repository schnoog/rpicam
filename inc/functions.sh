


###################################################################################
##
##  Get the Brightness from the Cam
#    1 = black 
#   10 = dark
#   80 = autumn grey
# >120 Sunny

function GetCamBrightness {
bright=$(raspistill -t 1 -w 128 -h 80 -ex off -o - | convert jpg:- -colorspace gray -resize 1x1 -format "%[pixel:p{0,0}]" info: | cut -d '(' -f 2 | cut -d ')' -f 1)
echo $bright
}

###################################################################################
##
## Get exposure from brightness value
#
#  raspistill parameter "-ex night" "-ex auto" "-ex verylong"
#
#
function GetEX {
out=""
case $1 in
[0-9])
	out="-ex night"
	;;
1[0-9])
	out="-ex night"
	;;
*)
	out="-ex auto"
	;;
esac
echo $out
}
###################################################################################
##
## Get white balance from brightness value
#
#  raspistill parameter "-awb sun" "-awb cloudshade" "-awb auto"
#
#
function GetAWB {
out="-awb auto"
tc=$1

if [ $tc -gt 200 ]
then
  out="-awb sun"	
else
  if [ $tc -gt 100 ]
  then
    out="-awb auto"
  else
    if [ $tc -gt 50 ]
    then
      out="-awb cloud"
    fi
  fi
fi
echo $out
}
###################################################################################
##
## Get ISO from brightness value
#
#  raspistill 
#
#
function GetISO {
out="-ISO 800"
tc=$1

if [ $tc -gt 250 ]
then
  out="-ISO 100"	
else
  if [ $tc -gt 80 ]
  then
    out="-ISO 200"
  else
    if [ $tc -gt 30 ]
    then
      out="-ISO 400"
    fi
  fi
fi
echo $out
}

###################################################################################
##
## TakeCroppedSizedPhotoFromGlobals "SavePath" "CamPercentage"
#  -> Takes a cam shot (adjusted ISO, EX, and AWB so brightness) with x% of the Cams resolution
#  --> Crops according to config
#
function TakeCroppedSizedPhotoFromGlobals {

	tmpfile="$RAMDIR""/tmppic.jpg"
	PSW=2592
	PSH=1944
	outfile="$1"
	PICP=$2
	GNEWW=$CROP_WIDTH
	GNEWH=$CROP_HEIGHT
	GLO=$CROP_LEFT
	GTO=$CROP_TOP

	br=$(GetCamBrightness)
	if [ $br -gt 50 ]
	then
	MAXTIME=20
	else
	MAXTIME=4000
	fi


	EX=$(GetEX $br)
	AWB=$(GetAWB $br)
	ISO=$(GetISO $br)
AWB=""
ISO=""
   ##
	SW=$(( $PSW * $PICP / 100 ))
	SH=$(( $PSH * $PICP / 100 ))
	NEWH=$(( $SH * $GNEWH / 100 ))
	TO=$(( $SH * $GTO / 100 ))
	NEWW=$(( $SW * $GNEWW / 100 ))
	LO=$(( $SW * $GLO / 100 ))
   ##
	CROPPARA="-crop "$NEWW"x"$NEWH"+"$LO"+"$TO
	cfg="-w $SW -h $SH  -hf -vf -t $MAXTIME -q 75 $EX $AWB $ISO -o ""$tmpfile"


	echo $cfg
	echo $CROPPARA

   raspistill $cfg
   convert "$tmpfile" $CROPPARA "$outfile" 
}


###################################################################################
##
## TakeCroppedSizedPhoto "SavePath" %CamResolution 42 76 20 23
#  -> Takes a cam shot (adjusted ISO, EX, and AWB so brightness) with x% of the Cams resolution
#  --> Crops an image With 42% With, 76% Heigth, 20% Left Offset, 23% Top Offset
#
function TakeCroppedSizedPhoto {

	PSW=2592
	PSH=1944
	outfile="$1"
	PICP=$2
	GNEWW=$3
	GNEWH=$4
	GLO=$5
	GTO=$6

	br=$(GetCamBrightness)
	EX=$(GetEX $br)
	AWB=$(GetAWB $br)
	ISO=$(GetISO $br)
   ##
	SW=$(( $PSW * $PICP / 100 ))
	SH=$(( $PSH * $PICP / 100 ))
	NEWH=$(( $SH * $GNEWH / 100 ))
	TO=$(( $SH * $GTO / 100 ))
	NEWW=$(( $SW * $GNEWW / 100 ))
	LO=$(( $SW * $GLO / 100 ))
   ##
	CROPPARA="-crop "$NEWW"x"$NEWH"+"$LO"+"$TO
	cfg="-w $SW -h $SH  -hf -vf -t 1 -q 100 $EX $AWB $ISO -o -"
echo "---------with $cfg" >> "$LOGFILE"

   raspistill $cfg | convert jpg:- $CROPPARA "$outfile" 
}
###################################################################################
##
## Create RAM Mount for tmp images
#
function CreateTMP {

	ismounted=$(mount |grep "$RAMDIR" | wc -l)
	if [ $ismounted -eq 0 ]
	then
	echo "MOUNTING $RAMDIR"
	   mount -t tmpfs -o size=20M none "$RAMDIR" 2>/dev/null
	fi
}

###################################################################################
##
function SnapImage {

	oldfile="$RAMDIR""/oldpic.jpg"
	outfile="$RAMDIR""/newpic.jpg"
	cp "$outfile" "$oldfile"

	PSW=2592
	PSH=1944
	PICP=$FAST_IMAGE_PERCENTAGE
	GNEWW=$CROP_WIDTH
	GNEWH=$CROP_HEIGHT
	GLO=$CROP_LEFT
	GTO=$CROP_TOP

	EX="-ex sports"
	AWB="-bm"
	ISO="-ISO 400"
   ##
	SW=$(( $PSW * $PICP / 100 ))
	SH=$(( $PSH * $PICP / 100 ))
	NEWH=$(( $SH * $GNEWH / 100 ))
	TO=$(( $SH * $GTO / 100 ))
	NEWW=$(( $SW * $GNEWW / 100 ))
	LO=$(( $SW * $GLO / 100 ))
   ##
	CROPPARA="-crop "$NEWW"x"$NEWH"+"$LO"+"$TO
	cfg="-w $SW -h $SH  -hf -vf -t 100 -q 100 $EX $AWB $ISO -o -"
   raspistill $cfg | convert jpg:- $CROPPARA "$outfile" 
}
###################################################################################
##
function CompareSnapShots {
SnapImage
	oldfile="$RAMDIR""/oldpic.jpg"
	newfile="$RAMDIR""/newpic.jpg"
	difffile="$RAMDIR""/diff.jpg"
ret=$(compare -fuzz 10% -metric ae "$oldfile" "$newfile" "$difffile" 2>&1 >/dev/null)
###compare "$oldfile" "$newfile" -compose Src -highlight-color White -lowlight-color Black "$difffile"
echo "$ret"
}
###################################################################################
##
function GetFirstFreeTLNum {
int=$STARTNUM
mf="$PICDIR""$int"".jpg"
while [ -a "$mf" ]
do
let int=$int+1
mf="$PICDIR""$int"".jpg"
done
echo $int
}
###################################################################################
##

###################################################################################
##

###################################################################################
##

###################################################################################
##




















