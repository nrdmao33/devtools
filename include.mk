# include.mk
# Define global things that all makefiles need.

BUILD_DIR := $(shell pwd)/../build
BUILD_BIN := $(BUILD_DIR)/bin
BUILD_LIB := $(BUILD_DIR)/lib

INSTALL_DIR := ${HOME}
INSTALL_BIN := $(INSTALL_DIR)/bin
INSTALL_LIB := $(INSTALL_DIR)/lib

SRCS := $(wildcard *.sh)
TOOLS := $(SRCS:%.sh=%)
BIN_TOOLS := $(TOOLS:%=$(BUILD_BIN)/%)

PY_SRCS := $(wildcard *.py)
PYBIN_TOOLS := $(PY_SRCS:%.py=$(BUILD_BIN)/%)

.PHONY: all install

all: $(BIN_TOOLS) $(PYBIN_TOOLS)

$(BIN_TOOLS): $(BUILD_BIN)/%: %.sh
	cp $< $@
	chmod +x $@

$(PYBIN_TOOLS): $(BUILD_BIN)/%: %.py
	cp $< $@
	chmod +x $@

install: $(BIN_TOOLS) $(PYBIN_TOOLS)
	for bin_tool in $^ ; do \
	    cp $$bin_tool $(INSTALL_BIN) ; \
	done

clean:
	rm $(BIN_TOOLS) $(PYBIN_TOOLS)
