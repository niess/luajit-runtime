PREFIX=     /usr/local
BUILD_TYPE= release

export BUILD_DIR= $(PWD)/build-$(BUILD_TYPE)
RUNTIME_EXE= $(BUILD_DIR)/bin/luajit-runtime

ifeq ($(BUILD_TYPE), release)
CFLAGS+= -O3
INSTALL_EXE= install -s
else ifeq ($(BUILD_TYPE), debug)
CFLAGS+= -O0 -g3
INSTALL_EXE= install
else
$(error invalid BUILD_TYPE $(BUILD_TYPE))
endif
export CFLAGS

FORCE:

${RUNTIME_EXE}: FORCE
	@echo "==== Building luajit-runtime executable ===="
	@$(MAKE) -e -C src
	@echo "==== Successfully built luajit-runtime executable ===="

install: ${RUNTIME_EXE}
	@echo "==== Installing luajit-runtime to $(PREFIX) ===="
	@install -d $(PREFIX)/bin
	@$(INSTALL_EXE) -m 0755 $(RUNTIME_EXE) $(PREFIX)/bin/luajit-runtime
	@echo "==== Successfully installed luajit-runtime to $(PREFIX) ===="
