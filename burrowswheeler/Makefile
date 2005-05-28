all:	bw bw-i mtf mtf-i huff huff-i do-test

clean:
	rm -f *.o bw bw-i mtf mtf-i huff huff-i

do-test:	bw bw-i mtf mtf-i huff huff-i
	cat test | ./bw | ./mtf | ./huff > test.x
	cat test.x | ./huff-i | ./mtf-i | ./bw-i > test.d
#	diff test test.d

bw:		bw.o
	gcc -o $@ bw.o

bw-i:	bw-i.o
	gcc -o $@ bw-i.o

mtf:	mtf.o
	gcc -o $@ mtf.o

mtf-i:	mtf-i.o
	gcc -o $@ mtf-i.o

huff:	huff.o huff-tree.o
	gcc -o $@ huff.o huff-tree.o

huff-i:	huff-i.o huff-tree.o
	gcc -o $@ huff-i.o huff-tree.o

