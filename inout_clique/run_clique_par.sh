#!/bin/bash
for f in clique*.in
do
	echo "Running input $f..."
	../parallel/clique.exe < $f > "${f%.*}_par.out"
done

