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
	git log -n1 --format=%h | tr -d '\n' > verstr.tex
	test -z "$$( git status -s | grep -v '^?? ' )" \
		|| echo -n '-dirty' >> verstr.tex

clean:
	rm -f *.pdf
