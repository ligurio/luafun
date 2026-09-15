#
# Makefile for generating the documentation from EmmyLua annotations
# with emmylua_doc_cli.
#

BUILD_DIR  := build
SITE_DIR   := site

EMMYLUA_DOC_CLI ?= emmylua_doc_cli

.PHONY: all docs serve check test clean

all: docs

docs:
	rm -rf $(SITE_DIR)
	python3 doc/build_site.py $(SITE_DIR)
	$(EMMYLUA_DOC_CLI) . -f html \
		--site-name "Lua Fun API" \
		--exclude "tests/**,repro/**,output/**,build/**,site/**,.rocks/**" \
		-o $(SITE_DIR)/api

serve: docs
	python3 -m http.server 8090 --directory $(SITE_DIR)

check:
	luacheck .
	emmylua_check .

test:
	cd tests && ./runtest *.lua

clean:
	rm -rf $(BUILD_DIR) $(SITE_DIR)
