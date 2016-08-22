#!/usr/bin/env bash -c make

SRC=./event-lite.js
ROLLED_SRC=./dist/event-lite.js
DEST=./dist/event-lite.min.js
TESTS=test/*.js
JSHINT=./node_modules/.bin/jshint
UGLIFYJS=./node_modules/.bin/uglifyjs
MOCHA=./node_modules/.bin/mocha
JSDOC=./node_modules/.bin/jsdoc
ROLLUP=./node_modules/.bin/rollup

DOCS_DIR=./gh-pages
DOC_HTML=./gh-pages/index.html
DOCS_CSS_SRC=./assets/jsdoc.css
DOCS_CSS_DEST=./gh-pages/styles/jsdoc-default.css

all: $(DEST) jsdoc

clean:
	rm -fr $(DEST)

$(ROLLED_SRC): $(SRC)
	$(ROLLUP) -c

$(DEST): $(ROLLED_SRC)
	$(UGLIFYJS) $(ROLLED_SRC) -c -m -o $(DEST)

test:
	@if [ "x$(BROWSER)" = "x" ]; then make test-node; else make test-browser; fi

test-node: jshint $(DEST)
	$(MOCHA) -R spec $(TESTS)

jshint:
	$(JSHINT) $(SRC) $(TESTS)

jsdoc: $(DOC_HTML)

test-browser:
	./node_modules/.bin/zuul -- $(TESTS)

test-browser-local:
	./node_modules/.bin/zuul --local -- $(TESTS)

$(DOC_HTML): README.md $(SRC) $(DOCS_CSS_SRC)
	mkdir -p $(DOCS_DIR)
	$(JSDOC) -d $(DOCS_DIR) -R README.md $(SRC)
	cat $(DOCS_CSS_SRC) >> $(DOCS_CSS_DEST)
	rm -f $(DOCS_DIR)/*.js.html
	for f in $(DOCS_DIR)/*.html; do sed 's#</a> on .* 201.* GMT.*##' < $$f > $$f~ && mv $$f~ $$f; done
	for f in $(DOCS_DIR)/*.html; do sed 's#<a href=".*.js.html">.*line.*line.*</a>##' < $$f > $$f~ && mv $$f~ $$f; done

.PHONY: all clean test jshint jsdoc
