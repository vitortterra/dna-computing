CC=gcc -O3 -Wall

all: set_cover.exe indep.exe clique.exe

set_cover.exe: set_cover.o wall_time.o dna.o
	$(CC) -o set_cover.exe set_cover.o wall_time.o dna.o

set_cover.o:
	$(CC) -c set_cover.c

indep.exe: indep.o wall_time.o dna.o
	$(CC) -o indep.exe indep.o wall_time.o dna.o

indep.o:
	$(CC) -c indep.c

clique.exe: clique.o wall_time.o dna.o
	$(CC) -o clique.exe clique.o wall_time.o dna.o

clique.o:
	$(CC) -c clique.c

dna.o:
	$(CC) -c dna.c

wall_time.o:
	$(CC) -c wall_time.c
	
clean:
	rm -rf *.o set_cover.exe indep.exe clique.exe
