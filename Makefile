# Top level makefile for all sub makefiles in the local directory structure.
#

# Support all, clean and install for all subdirs.
#
BUILD_DIR := $(shell pwd)/build
include dirs.mk

SUBDIRS = general linux net sandbox templates emacs git
SUBDIRS_ALL = $(SUBDIRS:%=all-%)
SUBDIRS_CLEAN = $(SUBDIRS:%=clean-%)
SUBDIRS_INSTALL = $(SUBDIRS:%=install-%)

.PHONY: all clean install $(SUBDIRS_ALL) $(SUBDIRS_CLEAN) $(SUBDIRS_INSTALL)

all: $(SUBDIRS_ALL)

clean: $(SUBDIRS_CLEAN)

install: $(SUBDIRS_INSTALL)

$(SUBDIRS_ALL):
	@if [ ! -d $(BUILD_DIR) ]; then mkdir -p $(BUILD_DIR); fi
	@if [ ! -d $(BUILD_BIN) ]; then mkdir -p $(BUILD_BIN); fi
	@if [ ! -d $(BUILD_LIB) ]; then mkdir -p $(BUILD_LIB); fi
	@if [ ! -d $(BUILD_FUNC) ]; then mkdir -p $(BUILD_FUNC); fi
	@if [ ! -d $(BUILD_EMACS) ]; then mkdir -p $(BUILD_EMACS); fi
	@if [ ! -d $(BUILD_DOT) ]; then mkdir -p $(BUILD_DOT); fi

	$(MAKE) $(MAKE_FLAGS) -C $(@:all-%=%)

$(SUBDIRS_CLEAN):
	$(MAKE) $(MAKE_FLAGS) -C $(@:clean-%=%) clean

$(SUBDIRS_INSTALL):
	@if [ ! -d $(INSTALL_DIR) ]; then mkdir -p $(INSTALL_DIR); fi
	@if [ ! -d $(INSTALL_BIN) ]; then mkdir -p $(INSTALL_BIN); fi
	@if [ ! -d $(INSTALL_LIB) ]; then mkdir -p $(INSTALL_LIB); fi
	@if [ ! -d $(INSTALL_FUNC) ]; then mkdir -p $(INSTALL_FUNC); fi
	@if [ ! -d $(INSTALL_EMACS) ]; then mkdir -p $(INSTALL_EMACS); fi
	$(MAKE) $(MAKE_FLAGS) -C $(@:install-%=%) install
