import random
import sys

if len(sys.argv) != 4:
    print("Usage: python filename minN maxN stepN")
    quit()

minN, maxN, stepN = [int(x) for x in sys.argv[1:]]

for n in xrange(minN, maxN + 1, stepN):
    for i in xrange(1, 6):
        filename = "cliqueN{0}_{1}.in".format(n, i)
        with open(filename, "w") as f:
            f.write(str(n) + '\n')
            adjacent = []
            for _ in xrange(n):
                adjacent.append([0] * n)
            for i in xrange(1, n):
                for j in xrange(i):
                    adjacent[i][j] = random.randint(0, 1)
                    adjacent[j][i] = adjacent[i][j]
            for row in adjacent:
                f.write(' '.join([str(x) for x in row]) + '\n')
