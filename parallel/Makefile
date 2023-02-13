CC=nvcc -arch=sm_30 -O3

all: set_cover.exe indep.exe clique.exe

set_cover.exe: set_cover.o wall_time.o dna.o
	$(CC) -o set_cover.exe set_cover.o wall_time.o dna.o

set_cover.o:
	$(CC) -c set_cover.cu

indep.exe: indep.o wall_time.o dna.o
	$(CC) -o indep.exe indep.o wall_time.o dna.o

indep.o:
	$(CC) -c indep.cu

clique.exe: clique.o wall_time.o dna.o
	$(CC) -o clique.exe clique.o wall_time.o dna.o

clique.o:
	$(CC) -c clique.cu

dna.o:
	$(CC) -c dna.cu

wall_time.o:
	$(CC) -c wall_time.cu

clean:
	rm -rf *.lib *.exp *.o set_cover.exe indep.exe clique.exe
