# This is only intended to work on a Darwin host.
# On the PPC (at least), it may only compile cleanly under Leopard.

NOW = $(shell date -u "+%F-%H-%M-%S")

GCC_VERSION = 5465
ARCH = $(shell arch)
ifeq ($(ARCH),i386)
PLATFORM = intel
else
PLATFORM = $(ARCH)
endif

package: compile
	mkdir -p ffigen/include ffigen/bin bin
	cp -p build/gcc/xlimits.h ffigen/include/limits.h
	cp -p gcc-$(GCC_VERSION)/gcc/ginclude/* ffigen/include
	(cd build/gcc ; tar cf - include | tar xf - -C ../../ffigen)
ifeq ($(ARCH),i386)
# Need to copy header files which describe intrinsics for 
# vector/fpu hardware
	cp -p gcc-$(GCC_VERSION)/gcc/config/i386/xmmintrin.h \
	      gcc-$(GCC_VERSION)/gcc/config/i386/tmmintrin.h \
	      gcc-$(GCC_VERSION)/gcc/config/i386/emmintrin.h \
	      gcc-$(GCC_VERSION)/gcc/config/i386/pmmintrin.h \
	      gcc-$(GCC_VERSION)/gcc/config/i386/pmm_malloc.h \
	      gcc-$(GCC_VERSION)/gcc/config/i386/gmm_malloc.h \
	      gcc-$(GCC_VERSION)/gcc/config/i386/mmintrin.h \
	      gcc-$(GCC_VERSION)/gcc/config/i386/mm3dnow.h \
	      ffigen/include
	mv ffigen/include/gmm_malloc.h ffigen/include/mm_malloc.h
endif
	cp -p build/gcc/cc1obj ffigen/bin/ffigen
	strip ffigen/bin/ffigen
	cp source/h-to-ffi.sh bin
	chmod +x bin/h-to-ffi.sh
	tar cvfz ffigen-apple-gcc-$(GCC_VERSION)-$(PLATFORM)-$(NOW).tar.gz bin ffigen



compile: patch
	mkdir build
	(cd build; ../gcc-$(GCC_VERSION)/configure --enable-languages=objc)	
	(cd build; ln -s . build-`../gcc-$(GCC_VERSION)/config.guess`)
	(cd build ; $(MAKE) maybe-configure-libiberty maybe-configure-gcc maybe-configure-libcpp maybe-configure-fixincludes)
	(cd build/libiberty ; $(MAKE))
	(cd build/intl ; $(MAKE))
	(cd build/libcpp ; $(MAKE))
	mkdir gcc
	(cd build/fixincludes ; $(MAKE))
	(cd build/gcc ; $(MAKE) cc1obj stmp-fixinc xlimits.h)


patch:	extract
	ln -sf `pwd`/source/ffi.c gcc-$(GCC_VERSION)/gcc
	printf "char *ffi_version = \42%s\42;\n" "$(NOW)" > \
	  gcc-$(GCC_VERSION)/gcc/ffi-version.h
	for f in source/gcc-$(GCC_VERSION)*.diff ; do \
	  (cd gcc-$(GCC_VERSION)/gcc; patch -p0 <../../$$f); \
	done


clean:
	rm -rf gcc-$(GCC_VERSION) build bin gcc ffigen*


extract: dist-gcc/gcc-$(GCC_VERSION).tar.gz clean
	tar fxz dist-gcc/gcc-$(GCC_VERSION).tar.gz


