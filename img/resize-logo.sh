#!/bin/sh

# This script resizes the logo art to the various bitmap sizes needed.

iconsdir_ios=`dirname $0`/../HIja\'/Assets.xcassets/AppIcon.appiconset

resize_ios() {
    size=$1
    scale=$2
    scaledsize=`echo "$size * $scale" | bc`

    convert -background '#313031' \
        `dirname $0`/logo.svg -resize ${scaledsize}x${scaledsize} \
        -depth 1 $iconsdir_ios/Icon-App-${size}x${size}@${scale}x.png
}

resize_ios 1024 1
resize_ios 20 1
resize_ios 20 2
resize_ios 20 3
resize_ios 29 1
resize_ios 29 2
resize_ios 29 3
resize_ios 40 1
resize_ios 40 2
resize_ios 40 3
resize_ios 60 2
resize_ios 60 3
resize_ios 76 1
resize_ios 76 2
resize_ios 83.5 2
