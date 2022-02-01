# include.mk
# Define global things that all makefiles need.
# Expected to be included from a subdirectory

BUILD_DIR := $(shell pwd)/../build
include ../dirs.mk

# Shell Scripts
SH_SRCS := $(wildcard *.sh)
BIN_TOOLS := $(SH_SRCS:%.sh=$(BUILD_BIN)/%)

PY_SRCS := $(wildcard *.py)
PYBIN_TOOLS := $(PY_SRCS:%.py=$(BUILD_BIN)/%)

FUNC_SRCS := $(wildcard *.func)
FUNC_LOAD := $(FUNC_SRCS:%.func=$(BUILD_FUNC)/%)

EMACS_SRCS := $(wildcard *.el)
EMACS_TOOLS := $(EMACS_SRCS:%=$(BUILD_EMACS)/%)

DOT_SRCS := $(wildcard *.dot)
DOT_TOOLS := $(DOT_SRCS:%.dot=$(BUILD_DOT)/.%)

.PHONY: all install install_funcs install_bin install_dot install_emacs

all: $(BIN_TOOLS) $(PYBIN_TOOLS) $(FUNC_LOAD) $(EMACS_TOOLS) $(DOT_TOOLS)

$(BIN_TOOLS): $(BUILD_BIN)/%: %.sh
	cp $< $@
	chmod +x $@

$(PYBIN_TOOLS): $(BUILD_BIN)/%: %.py
	cp $< $@
	chmod +x $@

$(FUNC_LOAD): $(BUILD_FUNC)/%: %.func
	cp $< $@
	chmod +x $@

$(EMACS_TOOLS): $(BUILD_EMACS)/%.el: %.el
	cp $< $@

$(DOT_TOOLS): $(BUILD_DOT)/.%: %.dot
	cp $< $@

install_bin: $(BIN_TOOLS) $(PYBIN_TOOLS)
	for bin_tool in $^ ; do \
	    cp $$bin_tool $(INSTALL_BIN) ; \
	done

install_funcs: $(FUNC_LOAD)
	for func_load in $^ ; do \
		cp $$func_load $(INSTALL_FUNC); \
	done

install_emacs: $(EMACS_TOOLS)
	for file in $^ ; do \
		cp $$file $(INSTALL_EMACS); \
	done

install_dot: $(DOT_TOOLS)
	for file in $^ ; do \
		cp $$file $(INSTALL_DOT) ; \
	done

install: install_bin install_funcs install_emacs install_dot

clean:
	rm $(BIN_TOOLS) $(PYBIN_TOOLS) $(FUNC_LOAD) $(EMACS_TOOLS) $(DOT_TOOLS)
