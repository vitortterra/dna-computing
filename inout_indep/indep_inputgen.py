import random
import sys

if len(sys.argv) != 7:
    print("Usage: python filename minN maxN minM maxM stepN stepM")
    quit()

minN, maxN, minM, maxM, stepN, stepM, = [int(x) for x in sys.argv[1:]]

for n in xrange(minN, maxN + 1, stepN):
    for m in xrange(minM, maxM + 1, stepM):
        for i in xrange(1, 6):
            filename = "indepN{0}M{1}_{2}.in".format(n, m, i)
            with open(filename, "w") as f:
                f.write(str(n) + '\n')
                f.write(str(m) + '\n')
                edgeset = set()
                while len(edgeset) < m:
                    v1, v2 = random.sample(xrange(n), 2)
                    edgeset.add((min(v1,v2), max(v1,v2)))
                for edge in edgeset:
                    f.write(' '.join([str(x) for x in edge]) + '\n')