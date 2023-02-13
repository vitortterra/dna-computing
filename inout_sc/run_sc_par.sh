#!/bin/bash
for f in sc*.in
do
	echo "Running input $f..."
	../parallel/set_cover.exe < $f > "${f%.*}_par.out"
done

