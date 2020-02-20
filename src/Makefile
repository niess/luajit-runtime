LUAJIT_REPO=     "https://github.com/openresty/luajit2.git"
LUAJIT_VERSION=  "v2.1-20200102"

INSPECT_REPO=    "https://github.com/kikito/inspect.lua.git"
INSPECT_VERSION= "b611db6"

LFS_REPO=        "https://github.com/keplerproject/luafilesystem.git"
LFS_VERSION=     "04bdaf9"

SOCKET_REPO=     "https://github.com/diegonehab/luasocket.git"
SOCKET_VERSION=  "733af88"

CC=     gcc
CFLAGS= -O3

JFLAGS= -g
ifdef CROSS
JFLAGS+= -o Windows
endif

BUILD_DIR=       $(PWD)/build
BUILD_MODE=      static
LUAJIT_OPTIONS=  BUILDMODE=static CFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT

LUAJIT_SRC=        $(BUILD_DIR)/src/luajit
LUAJIT_INC=        $(BUILD_DIR)/include/luajit-2.1
LUAJIT_EXE=        $(BUILD_DIR)/bin/luajit
LUAJIT_NATIVE_LIB= $(BUILD_DIR)/lib/libluajit-5.1.a
LUAJIT_LIB=        $(BUILD_DIR)/lib/libluajit-$(CROSS)5.1.a

define git_clone #([$1] = destination, [$2] = url, [$3] = tag)
	if [ ! -d "$1" ]; then \
	    echo "CLONE     $$(basename $1)" && \
	    git clone -q "$2" "$1" && \
	    cd "$1" && \
	    git checkout -q "$3"; \
	fi
endef

define jit_compile #([$1] = name, [$2] = source.lua, [$3] = object.o)
	echo "JIT       $$(basename $@)"
	$(LUAJIT_EXE) -b $(JFLAGS) -n $1 $2 $3
endef

.PHONY: clean

RUNTIME_EXE= $(BUILD_DIR)/bin/$(CROSS)luajit-runtime
RUNTIME_VERSION= $(shell \
    git describe --match=NeVeRmAtCh --always --abbrev=7 --dirty)

all: $(RUNTIME_EXE)

clean:
	@$(MAKE) --quiet -C $(LUAJIT_SRC)/src clean
	@$(MAKE) --quiet -C $(BUILD_DIR)/src/socket/src clean
	@cd $(BUILD_DIR) && \
	rm -rf bin include lib objs share pumas/*.h.lua

$(LUAJIT_SRC):
	@$(call git_clone,$@,$(LUAJIT_REPO),$(LUAJIT_VERSION))

$(LUAJIT_EXE) $(LUAJIT_NATIVE_LIB): $(LUAJIT_SRC)
	@$(MAKE) -C $< PREFIX=$(BUILD_DIR) CROSS= $(LUAJIT_OPTIONS)
	@$(MAKE) --quiet -C $< install PREFIX=$(BUILD_DIR) CROSS= $(LUAJIT_OPTIONS)
	@$(MAKE) --quiet -C $(LUAJIT_SRC)/src clean

ifdef CROSS
$(LUAJIT_LIB): $(LUAJIT_SRC)
	@cd $</src && \
	$(MAKE) CROSS=$(CROSS) TARGET_SYS=Windows $(LUAJIT_OPTIONS) && \
	echo "INSTALL   $$(basename $@)" && \
	mkdir -p $(BUILD_DIR)/lib && \
	mv libluajit.a $@
	@$(MAKE) --quiet -C $(LUAJIT_SRC)/src clean
endif

OBJS_DIR= $(BUILD_DIR)/objs

$(OBJS_DIR):
	@echo "MKDIR     $$(basename $@)"
	@mkdir -p $@

LFS_SRC= $(BUILD_DIR)/src/lfs
LFS_OBJ= $(OBJS_DIR)/$(CROSS)lfs.c.o

$(LFS_SRC)/src/lfs.c $(LFS_SRC)/src/lfs.h:
	@$(call git_clone,$(LFS_SRC),$(LFS_REPO),$(LFS_VERSION))

$(LFS_OBJ): $(LFS_SRC)/src/lfs.c $(LFS_SRC)/src/lfs.h | $(OBJS_DIR)
	@echo "CC        $$(basename $@)"
	@$(CROSS)$(CC) -o $@ -I$(LUAJIT_INC) -c $(CFLAGS) $<

SOCKET_SRC= $(BUILD_DIR)/src/socket
SOCKET_OBJS= $(OBJS_DIR)/$(CROSS)auxiliar.c.o \
	     $(OBJS_DIR)/$(CROSS)luasocket.c.o \
	     $(OBJS_DIR)/$(CROSS)timeout.c.o \
	     $(OBJS_DIR)/$(CROSS)buffer.c.o \
	     $(OBJS_DIR)/$(CROSS)mime.c.o \
	     $(OBJS_DIR)/$(CROSS)udp.c.o \
	     $(OBJS_DIR)/$(CROSS)compat.c.o \
	     $(OBJS_DIR)/$(CROSS)options.c.o \
	     $(OBJS_DIR)/$(CROSS)except.c.o \
	     $(OBJS_DIR)/$(CROSS)select.c.o \
	     $(OBJS_DIR)/$(CROSS)inet.c.o \
	     $(OBJS_DIR)/$(CROSS)io.c.o \
	     $(OBJS_DIR)/$(CROSS)tcp.c.o \
	     $(OBJS_DIR)/$(CROSS)ltn12.lua.o \
	     $(OBJS_DIR)/$(CROSS)mime.lua.o \
	     $(OBJS_DIR)/$(CROSS)socket.lua.o \
	     $(OBJS_DIR)/$(CROSS)socket_ftp.lua.o \
	     $(OBJS_DIR)/$(CROSS)socket_headers.lua.o \
	     $(OBJS_DIR)/$(CROSS)socket_http.lua.o \
	     $(OBJS_DIR)/$(CROSS)socket_smtp.lua.o \
	     $(OBJS_DIR)/$(CROSS)socket_tp.lua.o \
	     $(OBJS_DIR)/$(CROSS)socket_url.lua.o

.PRECIOUS: $(SOCKET_SRC)/src/%.c $(SOCKET_SRC)/src/%.lua
$(SOCKET_SRC)/src/%.c $(SOCKET_SRC)/src/%.lua:
	@$(call git_clone,$(SOCKET_SRC),$(SOCKET_REPO),$(SOCKET_VERSION))

SOCKET_FLAGS= LUAINC=$(LUAJIT_INC)
ifdef CROSS
SOCKET_FLAGS+= PLAT=mingw CC=$(CROSS)$(CC)
SOCKET_OBJS+= $(OBJS_DIR)/$(CROSS)wsocket.c.o
else
SOCKET_FLAGS+= PLAT=linux
SOCKET_OBJS+= $(OBJS_DIR)/$(CROSS)unix.c.o \
	      $(OBJS_DIR)/$(CROSS)usocket.c.o \
	      $(OBJS_DIR)/$(CROSS)unixstream.c.o \
	      $(OBJS_DIR)/$(CROSS)unixdgram.c.o \
	      $(OBJS_DIR)/$(CROSS)serial.c.o
endif

unexport CFLAGS
$(OBJS_DIR)/$(CROSS)%.c.o: $(SOCKET_SRC)/src/%.c
	@echo "CC        $$(basename $@)"
	@$(MAKE) --quiet -C $(SOCKET_SRC)/src $*.o $(SOCKET_FLAGS)
	@mv $(SOCKET_SRC)/src/$*.o $@

$(OBJS_DIR)/$(CROSS)socket_%.lua.o: $(SOCKET_SRC)/src/%.lua $(LUAJIT_EXE) | $(OBJS_DIR)
	@$(call jit_compile,socket.$*,$<,$@)

$(OBJS_DIR)/$(CROSS)%.lua.o: $(SOCKET_SRC)/src/%.lua $(LUAJIT_EXE) | $(OBJS_DIR)
	@$(call jit_compile,$*,$<,$@)

INSPECT_SRC= $(BUILD_DIR)/src/inspect

$(INSPECT_SRC)/inspect.lua:
	@$(call git_clone,$(INSPECT_SRC),$(INSPECT_REPO),$(INSPECT_VERSION))

$(OBJS_DIR)/$(CROSS)inspect.lua.o: $(INSPECT_SRC)/inspect.lua $(LUAJIT_EXE) | $(OBJS_DIR)
	@$(call jit_compile,inspect,$<,$@)

$(OBJS_DIR)/$(CROSS)%.lua.o: %.lua $(LUAJIT_EXE) | $(OBJS_DIR)
	@$(call jit_compile,$*,$<,$@)

$(OBJS_DIR)/$(CROSS)runtime_%.lua.o: runtime/%.lua $(LUAJIT_EXE) | $(OBJS_DIR)
	@$(call jit_compile,runtime.$*,$<,$@)

$(OBJS_DIR)/$(CROSS)runtime.lua.o: runtime/init.lua $(LUAJIT_EXE) | $(OBJS_DIR)
	@$(call jit_compile,runtime,$<,$@)

RUNTIME_OBJS= $(LFS_OBJ) \
	      $(SOCKET_OBJS) \
	      $(OBJS_DIR)/$(CROSS)inspect.lua.o \
	      $(OBJS_DIR)/$(CROSS)strict.lua.o \
	      $(OBJS_DIR)/$(CROSS)runtime.lua.o \
	      $(OBJS_DIR)/$(CROSS)runtime_repl.lua.o
RUNTIME_LIB=  $(BUILD_DIR)/lib/libruntime-$(CROSS)5.1.a

$(RUNTIME_LIB): $(RUNTIME_OBJS)
	@echo "AR        $$(basename $@)"
	@$(CROSS)ar rcs $@ $^

MAIN_OBJ= $(OBJS_DIR)/$(CROSS)runtime_main.o

$(MAIN_OBJ): runtime_main.c | $(OBJS_DIR) $(LUAJIT_EXE)
	@echo "CC        $$(basename $@)"
	@$(CROSS)$(CC) -o $@ -c -I$(LUAJIT_INC) $(CFLAGS) \
	               -DRUNTIME_VERSION="\"$(RUNTIME_VERSION)\"" $<

ifdef CROSS
EXPORT_SYMBOLS= -Wl,--export-all-symbols
else
EXPORT_SYMBOLS= -rdynamic
endif

ifeq ($(shell uname -s),Linux)
WHOLE_ARCHIVE=    -Wl,--whole-archive
NO_WHOLE_ARCHIVE= -Wl,--no-whole-archive
else
WHOLE_ARCHIVE=    -Wl,-all_load
NO_WHOLE_ARCHIVE= -Wl,-noall_load
endif

LDFLAGS+= $(WHOLE_ARCHIVE) $(EXPORT_SYMBOLS) \
          -L$(BUILD_DIR)/lib -lluajit-$(CROSS)5.1 -lruntime-$(CROSS)5.1 \
          $(NO_WHOLE_ARCHIVE)

ifdef CROSS
LDLIBS+= -lws2_32
else
LDLIBS+= -ldl -lm
endif

$(BUILD_DIR)/bin/$(CROSS)luajit-runtime: $(MAIN_OBJ) $(LUAJIT_LIB) $(RUNTIME_LIB)
	@echo "LINK      $$(basename $@)"
	@$(CROSS)$(CC) -o $@ $< $(LDFLAGS) $(LDLIBS)

