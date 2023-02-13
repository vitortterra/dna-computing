import os
import re
import csv
from collections import defaultdict

inittimes = defaultdict(list)
comptimes = defaultdict(list)
for filename in os.listdir("./"):
    if filename.startswith("indep") and filename.endswith(".out"):
        N = int(filename[6:8])
        M = int(filename[9:12].strip('_'))
        with open(filename, "r") as f:
            for line in f:
                if line.startswith("Elapsed"):
                    i = line.find("init")
                    init = float(line[i+5:i+14])
                    j = line.find("comp")
                    comp = float(line[j+5:j+14])
                    inittimes[(M,N)].append(init)
                    comptimes[(M,N)].append(comp)
with open("indepseq.csv", "wb") as csvfile:
    writer = csv.writer(csvfile, delimiter=';')
    writer.writerow(["M", "N", "mediana init", "mediana comp"])
    for mn in sorted(inittimes.keys()):
        M = mn[0]
        N = mn[1]
        medinit = sorted(inittimes[mn])[2]
        medcomp = sorted(comptimes[mn])[2]
        writer.writerow([M,N,medinit, medcomp])
