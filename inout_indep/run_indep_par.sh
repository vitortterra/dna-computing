#!/bin/bash
for f in indep*.in
do
	echo "Running input $f..."
	../parallel/indep.exe < $f > "${f%.*}_par.out"
done

