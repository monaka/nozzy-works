SOURCE:=$(wildcard *.tex)
DVIFILES:=$(SOURCE:%.tex=%.dvi)
PDFFILES:=$(SOURCE:%.tex=%.pdf)
RELEASEFILES:=$(SOURCE:%.tex=%.release-stamp)

all: $(PDFFILES)

check: all

%.pdf: %.dvi
	umask 002 ; dvipdfmx -o $@.tmp $<
	mv $@.tmp $@

%.dvi: %.tex
	platex -halt-on-error -kanji=jis $< # create draft input
	-mendex -J $(<:%.tex=%)
	platex -halt-on-error -kanji=jis $< # create draft content with correct spacing for index and toc
	-mendex -J $(<:%.tex=%)
	platex -halt-on-error -kanji=jis $< # recreate toc with correct page number

clean:
	-rm -f *.dvi *.aux *.toc *~ *.log *.waux *.out _whizzy_* *.snm *.nav *.jqz *.ind *.ilg *.idx *.idv *.lg *.xref *.4ct *.4tc *.css *.gz *fdb_latexmk
	# 一度全部のファイルをpublishしたものとみなす。古いファイルを全部アップロードするのを回避します
	-touch $(RELEASEFILES)

distclean: clean
	-rm -fr $(RELEASEFILES) $(PDFFILES) auto

.PHONY: clean all check
