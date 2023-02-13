import random
import sys

if len(sys.argv) != 7:
    print("Usage: python filename minA maxA minB maxB stepA stepB")
    quit()

minA, maxA, minB, maxB, stepA, stepB = [int(x) for x in sys.argv[1:]]


for A in xrange(minA, maxA + 1, stepA):
    for B in xrange(minB, maxB + 1, stepB):
        for i in xrange(1, 6):
            filename = "scA{0}B{1}_{2}.in".format(A, B, i)
            with open(filename, "w") as f:
                f.write(str(A) + '\n')
                f.write(str(B) + '\n')
                for _ in xrange(B):
                    #C0 = random.randint(1, A)
                    C0 = int(random.gauss(A/4, A/4))
                    C0 = max(min(C0, A), 1)
                    C = [C0] + random.sample(xrange(A), C0)
                    f.write(' '.join([str(x) for x in C]) + '\n')
