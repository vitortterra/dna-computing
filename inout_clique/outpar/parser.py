import os
import re
import csv
from collections import defaultdict

inittimes = defaultdict(list)
comptimes = defaultdict(list)
for filename in os.listdir("./"):
    if filename.startswith("clique") and filename.endswith(".out"):
        N = int(filename[7:9])
        with open(filename, "r") as f:
            for line in f:
                if line.startswith("Elapsed"):
                    i = line.find("init")
                    init = float(line[i+5:i+14])
                    j = line.find("comp")
                    comp = float(line[j+5:j+14])
                    inittimes[N].append(init)
                    comptimes[N].append(comp)
with open("cliquepar.csv", "wb") as csvfile:
    writer = csv.writer(csvfile, delimiter=';')
    writer.writerow(["N", "mediana init", "mediana comp"])
    for N in sorted(inittimes.keys()):
        medinit = sorted(inittimes[N])[2]
        medcomp = sorted(comptimes[N])[2]
        writer.writerow([N,medinit, medcomp])
