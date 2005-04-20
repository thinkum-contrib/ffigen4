OS = $(shell uname -s)
GCC_VERSION = 4.0-20050326
ARCHIVES = gcc-core-$(GCC_VERSION).tar.bz2 gcc-objc-$(GCC_VERSION).tar.bz2

ifeq ($(OS),Linux)
PLATFORM = linuxppc
CONFIGTARGET = ppc64-unknown-linux
CONFIGARGS = --target=$(CONFIGTARGET) --host=$(CONFIGTARGET) --with-cpu=default32 --enable-biarch --enable-threads=posix
MAKE_FUNKY_LINK = YES
COPY_OBJC_HEADERS = YES
endif

ifeq ($(OS),Darwin)
PLATFORM=darwinppc
CONFIGTARGET = powerpc-apple-darwin8
CONFIGARGS = --target=$(CONFIGTARGET) --with-cpu=default32 --enable-biarch
MAKE_FUNKY_LINK = YES
COPY_OBJC_HEADERS = NO
endif



all: package
	m4 -DPLATFORM=$(PLATFORM) -DGCC_VERSION=$(GCC_VERSION) source/INSTALL-$(PLATFORM).m4 > INSTALL-FFIGEN-$(PLATFORM)-gcc-$(GCC_VERSION).txt


compile: patch
	mkdir build
	(cd build ; ../gcc-$(GCC_VERSION)/configure --enable-languages=objc $(CONFIGARGS) )
ifeq ($(MAKE_FUNKY_LINK),YES)
ifeq ($(OS),Darwin)
	(cd build ; ln -s . build-`../gcc-$(GCC_VERSION)/config.guess`)
endif
ifeq ($(OS),Linux)
	(cd build ; ln -s . build-$(CONFIGTARGET))
endif
endif
	(cd build ; make maybe-configure-libiberty maybe-configure-gcc maybe-configure-libcpp)
	(cd build/libiberty ; make)
	(cd build/intl ; make)
	(cd build/libcpp ; make)
	(cd build/gcc ; make cc1obj xlimits.h)

patch: extract
	ln -sf `pwd`/source/ffi.c gcc-$(GCC_VERSION)/gcc
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
ifeq ($(COPY_OBJC_HEADERS), YES)
	cp -r -p gcc-$(GCC_VERSION)/libobjc/objc ffigen/include
endif
	mkdir ffigen/bin
	cp -p build/gcc/cc1obj ffigen/bin/ffigen
	strip ffigen/bin/ffigen
	tar cfz ffigen-bin-$(PLATFORM)-gcc-$(GCC_VERSION).tar.gz bin ffigen

clean:
	rm -rf gcc-$(GCC_VERSION) ffigen build bin ffigen*tar.gz INSTALL-FFIGEN-$(PLATFORM)-gcc-$(GCC_VERSION).txt

%.bz2:
	@echo
	@echo Obtain the file $@ from a GNU repository \(or gcc.gnu.org mirror\) and copy it to this directory.
	@echo
	@exit 2

extract: $(ARCHIVES) clean
	tar fxj gcc-core-$(GCC_VERSION).tar.bz2
	tar fxj gcc-objc-$(GCC_VERSION).tar.bz2
