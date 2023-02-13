#!/bin/bash
for f in indep*.in
do
	echo "Running input $f..."
	../sequential/indep.exe < $f > "${f%.*}_seq.out"
done
