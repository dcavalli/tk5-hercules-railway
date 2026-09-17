#!/bin/sh
# Seed the DASD volume on first start.
#
# Railway attaches a volume empty. Mounting it on /tk5/dasd would therefore
# hide the packs the image ships and the system would have nothing to IPL
# from. The image keeps a pristine copy at /tk5/dasd-seed, and this script
# copies it in the first time it finds the volume unseeded.
#
# The marker is a file inside the volume rather than a test for emptiness:
# a half-copied volume from an interrupted first start would look non-empty
# and would then never be repaired. With the marker, an interrupted seed is
# retried on the next start, because the marker is written last.
set -e

if [ ! -f /tk5/dasd/.seeded ]; then
    echo "railway: DASD volume is unseeded, copying the image's packs in"
    cp -a /tk5/dasd-seed/. /tk5/dasd/
    touch /tk5/dasd/.seeded
    echo "railway: seeded $(ls -1 /tk5/dasd | wc -l) entries"
else
    echo "railway: DASD volume already seeded, keeping what is on it"
fi

exec /tk5/mvs
