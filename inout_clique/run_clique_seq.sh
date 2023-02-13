#!/bin/bash
for f in clique*.in
do
	echo "Running input $f..."
	../sequential/clique.exe < $f > "${f%.*}_seq.out"
done
