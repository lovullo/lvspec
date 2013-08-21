# Builds specifications

.PHONY: default clean

default: lvspec.pdf

%.pdf: %.tex verstr.tex
	pdflatex $* \
		&& makeindex $(patsubst %.tex, %.idx, $<) \
		&& pdflatex $< \
		&& pdflatex $< \
		|| rm $@

# outputs a version string to uniquely identify the document revision
# TODO: use tag name if matches current commit
verstr.tex:
	./verstr >$@

clean:
	rm -f *.pdf
