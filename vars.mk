#
# vars.mk
#

HOST = $(shell echo $$MACHTYPE | sed "s/$$(echo $$MACHTYPE | cut -d- -f2)/cross/")
TARGET = aarch64-crux-linux-gnueabi

TOPDIR  = $(shell pwd)
CLFS = $(TOPDIR)/clfs
CROSSTOOLS = $(TOPDIR)/crosstools
WORK = $(TOPDIR)/work

KERNEL_HEADERS_VERSION = 4.14.34
LIBGMP_VERSION = 6.1.2
LIBMPFR_VERSION = 4.0.1
LIBMPC_VERSION = 1.1.0
BINUTILS_VERSION = 2.29.1
GCC_VERSION = 7.3.0
GLIBC_VERSION = 2.27

# Make jobs
MJ=-j2

# End of file
