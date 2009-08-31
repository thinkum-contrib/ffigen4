OS = $(shell uname -s)
NOW = $(shell date -u "+%F-%H-%M-%S")

GCC_VERSION = 4.3.1

PLATFORM = cocotron
targetPlatform = Windows
targetArchitecture = i386
gccVersion = $(GCC_VERSION)
installFolder = /Developer
productName = Cocotron
productVersion = 1.0
compilerTarget = i386-mingw32msvc
gmpVersion=4.2.3



productFolder=${installFolder}/$(productName)/$(productVersion)

downloadFolder=$(productFolder)/Downloads
sourceFolder=$(productFolder)/Source
interfaceFolder=$(productFolder)/PlatformInterfaces/$(compilerTarget)
buildFolder=$(productFolder)/build/$(targetPlatform)/$(targetArchitecture)
resultFolder=$(productFolder)/$(targetPlatform)/$(targetArchitecture)/gcc-$(gccVersion)
toolFolder=$(productFolder)/bin

ARCHIVES = $(downloadFolder)/gcc-$(GCC_VERSION).tar.bz2


CONFIGARGS= -v --prefix="$(resultFolder)" --target=$(compilerTarget) \
		--with-gnu-as --with-gnu-ld --with-headers=$(resultFolder)/$(compilerTarget)/include \
		--without-newlib --disable-multilib --disable-libssp --disable-nls --enable-languages="c,objc" \
		--with-gmp=$(buildFolder)/gmp-$(gmpVersion) --enable-decimal-float --with-mpfr=$(resultFolder) --enable-checking=release \
		--enable-objc-gc --disable-bootstrap


all: package


compile: patch
	mkdir build
	(cd build ; ../gcc-$(GCC_VERSION)/configure  $(CONFIGARGS) )
ifeq ($(MAKE_FUNKY_LINK),YES)
ifeq ($(OS),Darwin)
	(cd build ; ln -s . build-`../gcc-$(GCC_VERSION)/config.guess`)
endif
ifeq ($(OS),Linux)
	(cd build ; ln -s . build-$(CONFIGTARGET))
endif
ifeq ($(OS),FreeBSD)
	(cd build ; ln -s . build-$(CONFIGTARGET))
endif

endif
#	(cd build ; $(MAKE) maybe-configure-libiberty maybe-configure-gcc maybe-configure-libcpp maybe-configure-libdecnumber)
#	(cd build/libiberty ; $(MAKE))
#	(cd build/intl ; $(MAKE))
#	(cd build/libcpp ; $(MAKE))
#	(cd build/libdecnumber ; $(MAKE))
#	(cd build/gcc ; $(MAKE))
	(cd build ; $(MAKE))

patch: extract
	ln -sf `pwd`/source/ffi.c gcc-$(GCC_VERSION)/gcc
	printf "char *ffi_version = \42%s\42;\n" "$(NOW)" > gcc-$(GCC_VERSION)/gcc/ffi-version.h
	for f in source/gcc-$(GCC_VERSION)*.diff ; do \
	  (cd gcc-$(GCC_VERSION)/gcc; patch -p0 <../../$$f); \
	done

package: compile
	mkdir bin
	cp source/h-to-ffi.sh bin/
	chmod +x bin/h-to-ffi.sh
	mkdir ffigen
	cp -r -p gcc-$(GCC_VERSION)/gcc/ginclude ffigen
	mv ffigen/ginclude ffigen/include
	cp -p gcc-$(GCC_VERSION)/gcc/gsyslimits.h ffigen/include/syslimits.h
	mkdir ffigen/bin
	cp -p build/gcc/cc1obj ffigen/bin/ffigen
	strip ffigen/bin/ffigen
	tar cfz ffigen-bin-$(PLATFORM)-gcc-$(GCC_VERSION)-$(NOW).tar.gz bin ffigen

clean:
	rm -rf gcc-$(GCC_VERSION) ffigen build bin ffigen*tar.gz INSTALL-FFIGEN-$(PLATFORM)-gcc-$(GCC_VERSION)*.txt

%.bz2:
	@echo
	@echo Obtain the file $@ from a GNU repository \(or gcc.gnu.org mirror\) and copy it to this directory.
	@echo
	@exit 2

extract: $(ARCHIVES) clean
	tar fxj $(ARCHIVES)
