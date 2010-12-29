OS = $(shell uname -s)
NOW = $(shell date -u "+%F-%H-%M-%S")
TAR = tar
EXE =

GCC_VERSION = 4.1.0
ARCHIVES = gcc-core-$(GCC_VERSION).tar.bz2 gcc-objc-$(GCC_VERSION).tar.bz2

ifeq ($(OS),Linux)
ARCH = $(shell uname -m)
ifeq ($(ARCH), armv7l)
PLATFORM = linuxarm
CONFIGTARGET = armv7l-unknown-linux-gnueabi
COPY_OBJC_HEADERS = YES
endif
endif


all: package
	m4 -DPLATFORM=$(PLATFORM) -DGCC_VERSION=$(GCC_VERSION)-$(NOW) source/INSTALL-$(PLATFORM).m4 > INSTALL-FFIGEN-$(PLATFORM)-gcc-$(GCC_VERSION)-$(NOW).txt


compile: patch
	mkdir build
	(cd build ; ../gcc-$(GCC_VERSION)/configure --host=$(CONFIGTARGET) --target=$(CONFIGTARGET) --enable-languages=objc $(CONFIGARGS) --disable-bootstrap )
	(cd build ; $(MAKE))

patch: extract
	ln -sf `pwd`/source/ffi.c gcc-$(GCC_VERSION)/gcc
	printf "char *ffi_version = \42%s\42;\n" "$(NOW)" > gcc-$(GCC_VERSION)/gcc/ffi-version.h
	for f in source/gcc-$(GCC_VERSION)*.diff ; do \
	  (cd gcc-$(GCC_VERSION)/gcc; patch -p0 <../../$$f); \
	done

package: compile
	mkdir bin
	cat source/$(PLATFORM)-gcc-$(GCC_VERSION)-h-to-ffi.sh source/h-to-ffi-common >  bin/h-to-ffi.sh
	chmod +x bin/h-to-ffi.sh
	mkdir ffigen
	cp -r -p gcc-$(GCC_VERSION)/gcc/ginclude ffigen
	mv ffigen/ginclude ffigen/include
	cp -p build/gcc/xlimits.h ffigen/include/limits.h
	cp -p gcc-$(GCC_VERSION)/gcc/gsyslimits.h ffigen/include/syslimits.h
ifeq ($(COPY_OBJC_HEADERS), YES)
	cp -r -p gcc-$(GCC_VERSION)/libobjc/objc ffigen/include
endif
	mkdir ffigen/bin
	cp -p build/gcc/cc1obj$(EXE) ffigen/bin/ffigen$(EXE)
	strip ffigen/bin/ffigen$(EXE)
	$(TAR) cfz ffigen-bin-$(PLATFORM)-gcc-$(GCC_VERSION)-$(NOW).tar.gz bin ffigen

clean:
	rm -rf gcc-$(GCC_VERSION) ffigen build bin ffigen*tar.gz INSTALL-FFIGEN-$(PLATFORM)-gcc-$(GCC_VERSION)*.txt

%.bz2:
	@echo
	@echo Obtain the file $@ from a GNU repository \(or gcc.gnu.org mirror\) and copy it to this directory.
	@echo
	@exit 2

extract: $(ARCHIVES) clean
	$(TAR) fxj gcc-core-$(GCC_VERSION).tar.bz2
	$(TAR) fxj gcc-objc-$(GCC_VERSION).tar.bz2
