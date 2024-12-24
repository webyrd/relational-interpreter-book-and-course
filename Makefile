INTERP = interp
SRC = $(wildcard *.tex *.bib chapters/*.tex)
FIG = $(wildcard images/*.pdf images/*.png images/*.jpg images/*.eps)

all: ${INTERP}.pdf ${INTERP}.md

${INTERP}.pdf: $(SRC) $(FIGS) ${INTERP}.tex
	latexmk -pdflatex=xelatex -pdf -latexoption=-halt-on-error -latexoption=-interaction=nonstopmode ${INTERP}.tex

${INTERP}.md: $(SRC) $(FIGS) ${INTERP}.tex
	pandoc -s -o ${INTERP}.md ${INTERP}.tex

clean:
	rm -f ${INTERP}.aux
	rm -f ${INTERP}.bbl
	rm -f ${INTERP}.bcf
	rm -f ${INTERP}.blg
	rm -f *.cpt
	rm -f ${INTERP}.fdb_latexmk
	rm -f ${INTERP}.fls
	rm -f ${INTERP}.idx
	rm -f ${INTERP}.ilg
	rm -f ${INTERP}.ind
	rm -f ${INTERP}.log
	rm -f ${INTERP}.mw
	rm -f ${INTERP}.out
	rm -f ${INTERP}.run.xml
	rm -f ${INTERP}.toc
	touch ${INTERP}.tex

squeaky: clean
	rm -f ${INTERP}.pdf
	rm -f ${INTERP}.md
