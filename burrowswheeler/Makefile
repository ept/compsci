all:	bw bw-i mtf mtf-i huff huff-i

clean:
	rm -f *.o bw bw-i mtf mtf-i huff huff-i

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

