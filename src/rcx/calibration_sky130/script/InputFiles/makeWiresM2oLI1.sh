#!/bin/bash

WIRE="C wire_LI1_W017L320.txt"
DIE="3.9e-6"
XZ="0.0"

FILE=wires_M2oLI1_W017W014_L032L140.txt
if test -f "$FILE"; then
	echo "$FILE exits."
else
	echo "* " > $FILE
fi

spacing=17
offset=0
thickness=17
tmp=0

for count in {0..43}
do
	tmp=$((count*spacing + count*thickness))
	offset=$(bc <<< "scale=2; $tmp/100")
	
	echo "$WIRE  $DIE    $XZ $offset $XZ" >> $FILE
done
