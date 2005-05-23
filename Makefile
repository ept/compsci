.SUFFIXES: .java .class .tex .dvi .ps .pdf

.java.class:
	gcj $<

.tex.dvi:
	latex $<

.dvi.ps:
	dvips -t landscape $<

.ps.pdf:
	gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -sOutputFile=$@ $<

demo1.tex:	CombinatorReduction.class
	gij --cp . CombinatorReduction '(S(SKK)(SKK))(S(SKK)(SKK))' 9 > $@

demo2.tex:	CombinatorReduction.class
	gij --cp . CombinatorReduction 'S1I1I2(S2(K1f)(S3I3I4))' 5 > $@

clean:
	rm -rf *.tex *.aux *.log *.dvi *.ps *.class

