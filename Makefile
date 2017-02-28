#
# Makefile
#

include vars.mk

.PHONY: all clean distclean

all: linux-headers libgmp libmpfr libmpc binutils gcc-static glibc gcc-final setup test

clean: linux-headers-clean libgmp-clean libmpfr-clean libmpc-clean binutils-clean gcc-static-clean glibc-clean gcc-final-clean test-clean
	rm -rf $(CROSSTOOLS) $(CLFS)

distclean: clean linux-headers-distclean libgmp-distclean libmpfr-distclean libmpc-distclean binutils-distclean gcc-static-distclean glibc-distclean gcc-final-distclean test-distclean


# LINUX HEADERS
$(WORK)/linux-$(KERNEL_HEADERS_VERSION).tar.xz:
	wget -P $(WORK) -c https://www.kernel.org/pub/linux/kernel/v4.x/linux-$(KERNEL_HEADERS_VERSION).tar.xz

$(WORK)/linux-$(KERNEL_HEADERS_VERSION): $(WORK)/linux-$(KERNEL_HEADERS_VERSION).tar.xz
	tar -C $(WORK) -xf $(WORK)/linux-$(KERNEL_HEADERS_VERSION).tar.xz
	touch $(WORK)/linux-$(KERNEL_HEADERS_VERSION)

$(CLFS)/usr/include/asm: $(WORK)/linux-$(KERNEL_HEADERS_VERSION)
	mkdir -p $(CLFS)/usr/include
	cd $(WORK)/linux-$(KERNEL_HEADERS_VERSION) && \
		make mrproper && \
		make ARCH=arm64 headers_check && \
		make ARCH=arm64 INSTALL_HDR_PATH=$(CLFS)/usr headers_install
	touch $(CLFS)/usr/include/asm

linux-headers: $(CLFS)/usr/include/asm

linux-headers-clean:
	rm -rf $(WORK)/linux-$(KERNEL_HEADERS_VERSION)

linux-headers-distclean: linux-headers-clean
	rm -f $(WORK)/linux-$(KERNEL_HEADERS_VERSION).tar.xz


# LIBGMP
$(WORK)/gmp-$(LIBGMP_VERSION).tar.bz2:
	wget -P $(WORK) -c ftp://ftp.gnu.org/gnu/gmp/gmp-$(LIBGMP_VERSION).tar.bz2

$(WORK)/gmp-$(LIBGMP_VERSION): $(WORK)/gmp-$(LIBGMP_VERSION).tar.bz2
	tar -C $(WORK) -xjf $(WORK)/gmp-$(LIBGMP_VERSION).tar.bz2
	touch $(WORK)/gmp-$(LIBGMP_VERSION)

$(WORK)/build-libgmp: $(WORK)/gmp-$(LIBGMP_VERSION)
	mkdir -p $(WORK)/build-libgmp
	touch $(WORK)/build-libgmp

$(CROSSTOOLS)/lib/libgmp.so: $(WORK)/build-libgmp
	cd $(WORK)/build-libgmp && \
		unset CFLAGS && unset CXXFLAGS && \
		CPPFLAGS=-fexceptions \
		$(WORK)/gmp-$(LIBGMP_VERSION)/configure --prefix=$(CROSSTOOLS) --enable-cxx && \
		make $(MJ) && make install || exit 1
	touch $(CROSSTOOLS)/lib/libgmp.so

libgmp: $(CROSSTOOLS)/lib/libgmp.so

libgmp-clean:
	rm -rf $(WORK)/build-libgmp $(WORK)/gmp-$(LIBGMP_VERSION)

libgmp-distclean: libgmp-clean
	rm -rf $(WORK)/gmp-$(LIBGMP_VERSION).tar.bz2


# LIBMPFR
$(WORK)/mpfr-$(LIBMPFR_VERSION).tar.bz2:
	wget -P $(WORK) -c http://ftp.gnu.org/gnu/mpfr/mpfr-$(LIBMPFR_VERSION).tar.bz2

$(WORK)/mpfr-$(LIBMPFR_VERSION): $(WORK)/mpfr-$(LIBMPFR_VERSION).tar.bz2
	tar -C $(WORK) -xjf $(WORK)/mpfr-$(LIBMPFR_VERSION).tar.bz2
	touch $(WORK)/mpfr-$(LIBMPFR_VERSION)

$(WORK)/build-libmpfr: $(WORK)/mpfr-$(LIBMPFR_VERSION)
	mkdir -p $(WORK)/build-libmpfr
	touch $(WORK)/build-libmpfr

$(CROSSTOOLS)/lib/libmpfr.so: $(WORK)/build-libmpfr
	cd $(WORK)/build-libmpfr && \
		unset CFLAGS && unset CXXFLAGS && \
		LDFLAGS="-Wl,-rpath,$(CROSSTOOLS)/lib" && \
		$(WORK)/mpfr-$(LIBMPFR_VERSION)/configure --prefix=$(CROSSTOOLS) --enable-shared --with-gmp=$(CROSSTOOLS) && \
		make $(MJ) && make install || exit 1
	touch $(CROSSTOOLS)/lib/libmpfr.so

libmpfr: $(CROSSTOOLS)/lib/libmpfr.so

libmpfr-clean:
	rm -rf $(WORK)/build-libmpfr $(WORK)/mpfr-$(LIBMPFR_VERSION)

libmpfr-distclean: libmpfr-clean
	rm -rf $(WORK)/mpfr-$(LIBMPFR_VERSION).tar.bz2


# LIBMPC
$(WORK)/mpc-$(LIBMPC_VERSION).tar.gz:
	wget -P $(WORK) -c http://www.multiprecision.org/mpc/download/mpc-$(LIBMPC_VERSION).tar.gz

$(WORK)/mpc-$(LIBMPC_VERSION): $(WORK)/mpc-$(LIBMPC_VERSION).tar.gz
	tar -C $(WORK) -xzf $(WORK)/mpc-$(LIBMPC_VERSION).tar.gz
	touch $(WORK)/mpc-$(LIBMPC_VERSION)

$(WORK)/build-libmpc: $(WORK)/mpc-$(LIBMPC_VERSION)
	mkdir -p $(WORK)/build-libmpc
	touch $(WORK)/build-libmpc

$(CROSSTOOLS)/lib/libmpc.so: $(WORK)/build-libmpc
	cd $(WORK)/build-libmpc && \
		unset CFLAGS && unset CXXFLAGS && \
		LDFLAGS="-Wl,-rpath,$(CROSSTOOLS)/lib" && \
		$(WORK)/mpc-$(LIBMPC_VERSION)/configure --prefix=$(CROSSTOOLS) \
		--enable-shared --with-gmp=$(CROSSTOOLS) --with-mpfr=$(CROSSTOOLS) && \
		make $(MJ) && make install || exit 1
	touch $(CROSSTOOLS)/lib/libmpc.so

libmpc: $(CROSSTOOLS)/lib/libmpc.so

libmpc-clean:
	rm -rf $(WORK)/build-libmpc $(WORK)/mpc-$(LIBMPC_VERSION)

libmpc-distclean: libmpc-clean
	rm -rf $(WORK)/mpc-$(LIBMPC_VERSION).tar.bz2


# BINUTILS
$(WORK)/binutils-$(BINUTILS_VERSION).tar.bz2:
	wget -P $(WORK) -c ftp://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VERSION).tar.bz2

$(WORK)/binutils-$(BINUTILS_VERSION): $(WORK)/binutils-$(BINUTILS_VERSION).tar.bz2
	tar -C $(WORK) -xf $(WORK)/binutils-$(BINUTILS_VERSION).tar.bz2
	sed -i '/^SUBDIRS/s/doc//' $(WORK)/binutils-$(BINUTILS_VERSION)/*/Makefile.in
	touch $(WORK)/binutils-$(BINUTILS_VERSION)

$(WORK)/build-binutils: $(WORK)/binutils-$(BINUTILS_VERSION)
	mkdir -p $(WORK)/build-binutils
	touch $(WORK)/build-binutils

$(CLFS)/usr/include/libiberty.h: $(WORK)/build-binutils
	cd $(WORK)/build-binutils && \
		unset CFLAGS && unset CXXFLAGS && \
		AR=ar AS=as \
		$(WORK)/binutils-$(BINUTILS_VERSION)/configure --prefix=$(CROSSTOOLS) \
		--host=$(HOST) --target=$(TARGET) --with-sysroot=$(CLFS) \
		--disable-nls --enable-shared --disable-multilib --enable-interwork && \
		make configure-host && make $(MJ) && make install || exit 1
	cp -va $(WORK)/binutils-$(BINUTILS_VERSION)/include/libiberty.h $(CLFS)/usr/include
	touch $(CLFS)/usr/include/libiberty.h
		
binutils: linux-headers $(CLFS)/usr/include/libiberty.h

binutils-clean:
	rm -rf $(WORK)/build-binutils $(WORK)/binutils-$(BINUTILS_VERSION)

binutils-distclean: binutils-clean
	rm -f $(WORK)/binutils-$(BINUTILS_VERSION).tar.bz2


# GCC-STATIC
$(WORK)/gcc-$(GCC_VERSION).tar.bz2:
	wget -P $(WORK) -c ftp://gcc.gnu.org/pub/gcc/releases/gcc-$(GCC_VERSION)/gcc-$(GCC_VERSION).tar.bz2

$(WORK)/gcc-$(GCC_VERSION): $(WORK)/gcc-$(GCC_VERSION).tar.bz2
	tar -C $(WORK) -xjf $(WORK)/gcc-$(GCC_VERSION).tar.bz2
	touch $(WORK)/gcc-$(GCC_VERSION)

$(WORK)/build-gcc-static: $(WORK)/gcc-$(GCC_VERSION)
	mkdir -p $(WORK)/build-gcc-static
	touch $(WORK)/build-gcc-static

$(CROSSTOOLS)/lib/gcc: $(WORK)/build-gcc-static $(WORK)/gcc-$(GCC_VERSION)
	cd $(WORK)/build-gcc-static && \
		unset CFLAGS && unset CXXFLAGS && \
		AR=ar LDFLAGS="-Wl,-rpath,$(CROSSTOOLS)/lib" \
		$(WORK)/gcc-$(GCC_VERSION)/configure --prefix=$(CROSSTOOLS) \
		--build=$(HOST) --host=$(HOST) --target=$(TARGET) \
		--disable-multilib --disable-nls \
		--without-headers --enable-__cxa_atexit --enable-symvers=gnu --disable-decimal-float \
		--disable-libgomp --disable-libmudflap --disable-libssp \
		--with-mpfr=$(CROSSTOOLS) --with-gmp=$(CROSSTOOLS) --with-mpc=$(CROSSTOOLS) \
		--disable-shared --disable-threads --enable-languages=c --disable-libquadmath && \
		make $(MJ) all-gcc all-target-libgcc && make install-gcc install-target-libgcc || exit 1
	touch $(CROSSTOOLS)/lib/gcc

gcc-static: linux-headers libgmp libmpfr binutils $(CROSSTOOLS)/lib/gcc

gcc-static-clean:
	rm -rf $(WORK)/build-gcc-static $(WORK)/gcc-$(GCC_VERSION)

gcc-static-distclean: gcc-static-clean
	rm -f $(WORK)/gcc-$(GCC_VERSION).tar.bz2


# GLIBC
$(WORK)/glibc-$(GLIBC_VERSION).tar.bz2:
	wget -P $(WORK) -c ftp://ftp.gnu.org/gnu/glibc/glibc-$(GLIBC_VERSION).tar.bz2

$(WORK)/glibc-$(GLIBC_VERSION): $(WORK)/glibc-$(GLIBC_VERSION).tar.bz2
	tar -C $(WORK) -xjf $(WORK)/glibc-$(GLIBC_VERSION).tar.bz2
	touch $(WORK)/glibc-$(GLIBC_VERSION)

$(WORK)/build-glibc: $(WORK)/glibc-$(GLIBC_VERSION)
	mkdir -p $(WORK)/build-glibc
	touch $(WORK)/build-glibc
	
$(CLFS)/usr/lib64/libc.so: $(WORK)/build-glibc $(WORK)/glibc-$(GLIBC_VERSION)
	cd $(WORK)/build-glibc && \
		export PATH=$(CROSSTOOLS)/bin:$$PATH && \
		echo "libc_cv_forced_unwind=yes" > config.cache && \
		echo "install_root=$(CLFS)" > configparms && \
		unset CFLAGS && unset CXXFLAGS && \
		BUILD_CC="gcc" CC="$(TARGET)-gcc" AR="$(TARGET)-ar" \
		RANLIB="$(TARGET)-ranlib" \
		$(WORK)/glibc-$(GLIBC_VERSION)/configure --prefix=/usr \
		--libexecdir=/usr/lib --host=$(TARGET) --build=$(HOST) \
		--enable-multi-arch --disable-profile --enable-add-ons --with-tls --enable-kernel=2.6.0 \
		--with-__thread --with-binutils=$(CROSSTOOLS)/bin --with-fp=yes --enable-obsolete-rpc \
		--with-headers=$(CLFS)/usr/include --cache-file=config.cache && \
		make $(MJ) && make install install_root=${CLFS} || exit 1
	touch $(CLFS)/usr/lib64/libc.so

glibc: binutils gcc-static $(CLFS)/usr/lib64/libc.so

glibc-clean:
	rm -rf $(WORK)/build-glibc $(WORK)/glibc-$(GLIBC_VERSION)

glibc-distclean: glibc-clean
	rm -f $(WORK)/glibc-$(GLIBC_VERSION).tar.bz2 $(WORK)/glibc-ports-$(GLIBC_VERSION).tar.bz2


# GCC-FINAL
$(WORK)/build-gcc-final: $(WORK)/gcc-$(GCC_VERSION)
	mkdir -p $(WORK)/build-gcc-final
	touch $(WORK)/build-gcc-final

$(CLFS)/lib/gcc: $(WORK)/build-gcc-final $(WORK)/gcc-$(GCC_VERSION)
	cd $(WORK)/build-gcc-final && \
		export PATH=$$PATH:$(CROSSTOOLS)/bin && \
		unset CFLAGS && unset CXXFLAGS && unset CC && \
		AR=ar LDFLAGS="-Wl,-rpath,$(CROSSTOOLS)/lib" \
		$(WORK)/gcc-$(GCC_VERSION)/configure --prefix=$(CROSSTOOLS) \
		--build=$(HOST) --host=$(HOST) --target=$(TARGET) \
		--with-headers=$(CLFS)/usr/include --enable-shared  \
		--disable-multilib  --with-sysroot=$(CLFS) --disable-nls \
		--enable-languages=c,c++ --enable-__cxa_atexit \
		--enable-threads=posix --disable-libstdcxx-pch --disable-bootstrap \
		--disable-libgomp --disable-libssp --disable-libmudflap \
		--with-mpfr=$(CROSSTOOLS) --with-gmp=$(CROSSTOOLS) --with-mpc=$(CROSSTOOLS) && \
		make $(MJ) AS_FOR_TARGET="$(TARGET)-as" LD_FOR_TARGET="$(TARGET)-ld" && \
		make install || exit 1
	cp -va $(WORK)/build-gcc-final/$(TARGET)/libstdc++-v3/src/.libs/libstdc++.so* $(CLFS)/usr/lib
	cp -va $(WORK)/build-gcc-final/$(TARGET)/libgcc/libgcc_s.so* $(CLFS)/usr/lib
	touch $(CLFS)/lib/gcc
		
gcc-final: libgmp libmpfr glibc $(CLFS)/lib/gcc

gcc-final-clean:
	rm -rf $(WORK)/build-gcc-final $(WORK)/gcc-$(GCC_VERSION)

gcc-final-distclean: gcc-final-clean
	rm -f $(WORK)/gcc-$(GCC_VERSION).tar.bz2


# SETUP FOR PKGUTILS-CROSS
$(CLFS)/var/lib/pkg/db:
	install -d -m 0755 $(CLFS)/var/lib/pkg
	touch $(CLFS)/var/lib/pkg/db

setup: $(CLFS)/var/lib/pkg/db


# TEST THE TOOLCHAIN
$(WORK)/test: $(WORK)/test.c
	export PATH=$$PATH:$(CROSSTOOLS)/bin && \
	unset CFLAGS && unset CXXFLAGS && unset CC && \
	AR=ar LDFLAGS="-Wl,-rpath,$(CROSSTOOLS)/lib" \
	$(TARGET)-gcc -Wall -o $(WORK)/test $(WORK)/test.c
	touch $(WORK)/test

test: gcc-final $(WORK)/test

test-clean:
	rm -rf $(WORK)/test

test-distclean: test-clean


# End of file
