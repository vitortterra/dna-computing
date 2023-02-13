#!/bin/bash
for f in sc*.in
do
	echo "Running input $f..."
	../sequential/set_cover.exe < $f > "${f%.*}_seq.out"
done

