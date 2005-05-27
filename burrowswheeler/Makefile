all:	bw bw-i mtf mtf-i

clean:
	rm -f *.o bw bw-i

bw:		bw.o
	gcc -o $@ $<

bw-i:	bw-i.o
	gcc -o $@ $<

mtf:	mtf.o
	gcc -o $@ $<

mtf-i:	mtf-i.o
	gcc -o $@ $<

