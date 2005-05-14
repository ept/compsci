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
	gij --cp . CombinatorReduction '(S(SKK)(SKK))(S(SKK)(SKK))' 9 > demo1.tex

clean:
	rm -rf *.tex *.aux *.log *.dvi *.ps *.class

