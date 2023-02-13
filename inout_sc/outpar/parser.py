import os
import re
import csv
from collections import defaultdict

inittimes = defaultdict(list)
comptimes = defaultdict(list)
for filename in os.listdir("./"):
    if filename.startswith("sc") and filename.endswith(".out"):
        A = int(filename[3:5])
        B = int(filename[6:8])
        with open(filename, "r") as f:
            for line in f:
                if line.startswith("Elapsed"):
                    i = line.find("init")
                    init = float(line[i+5:i+14])
                    j = line.find("comp")
                    comp = float(line[j+5:j+14])
                    inittimes[(A,B)].append(init)
                    comptimes[(A,B)].append(comp)
with open("sc.csv", "wb") as csvfile:
    writer = csv.writer(csvfile, delimiter=';')
    writer.writerow(["A", "B", "mediana init", "mediana comp"])
    for ab in sorted(inittimes.keys()):
        A = ab[0]
        B = ab[1]
        medinit = sorted(inittimes[ab])[2]
        medcomp = sorted(comptimes[ab])[2]
        writer.writerow([A,B,medinit, medcomp])
