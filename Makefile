
#
# Compose :: Melbourne 2016 Haskell Workshop
#
# * http://composeconference.github.io/compose_haskell_workshop/
# * https://github.com/composeconference/compose_haskell_workshop
#

WHITELIST := 'README\|Makefile\|resources/'

CHAPTERS := README.md dependencies/TOC.md \
	$(shell sed -n '/^[^ ;].*|/ s|^\([^ ]*\).*|resources/markdown/\1.md|p' \
	resources/markdown/TOC.md)

all: mkdependencies html todo

.PHONY: mkdependencies
mkdependencies:
	mkdir -p dependencies

html:
	@ grep -v '^;' resources/markdown/TOC.md | sed 's/.*|//'     > dependencies/TOC.md
	@ cat  resources/html/head.html                              > index.html
	@ resources/scripts/wrapchapters.sh pandoctor $(CHAPTERS)   >> index.html
	@ cat  resources/html/footer.html                           >> index.html

standalone: html
	inliner -m 'index.html' > compose_melbourne_2016_haskell_workshop_standalone.html

display: html
	@ ./resources/scripts/chromereload index.html

devel:
	open index.html
	commando -p cat -q -j                     \
	| grep --line-buffered -v 'dependencies/' \
	| grep --line-buffered -v 'dot/'          \
	| grep --line-buffered -v 'git'           \
	| grep --line-buffered    $(WHITELIST)    \
	| uniqhash                                \
	| conscript make display

todo: unchecked_examples
	@ grep -ni todo $(CHAPTERS) | cat

publish:
	make
	git add -A .
	@ echo "Commit Message:"
	@ read message; \
	git commit -m "Publishing - $$message"
	git push
	git push origin gh-pages

dependencies:
	mkdir -p dependencies
	git clone git@github.com:sordina/Commando.git  dependencies/commando
	git clone git@github.com:sordina/Conscript.git dependencies/conscript
	git clone git@github.com:sordina/pandoctor.git dependencies/pandoctor
	git clone git@github.com:sordina/uniqhash.git  dependencies/uniqhash
	cd dependencies/commando  && cabal install
	cd dependencies/conscript && cabal install
	cd dependencies/pandoctor && cabal install
	cd dependencies/uniqhash  && cabal install

clean:
	rm -rf dependencies
	mkdir dependencies
	rm -f /tmp/haskell_workshop_md5_*
	rm -f /tmp/haskell_workshop.*.cache
	rm -f /tmp/ghc_results_*
	rm -f /tmp/haskell_workshop_check.*

unchecked_examples:
	@ grep -n 'data-language=haskell' $(CHAPTERS) | grep -v check | cat
