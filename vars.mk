#
# vars.mk
#

HOST = $(shell echo $$MACHTYPE | sed "s/$$(echo $$MACHTYPE | cut -d- -f2)/cross/")
TARGET = aarch64-crux-linux-gnueabi

TOPDIR  = $(shell pwd)
CLFS = $(TOPDIR)/clfs
CROSSTOOLS = $(TOPDIR)/crosstools
WORK = $(TOPDIR)/work

KERNEL_HEADERS_VERSION = 4.1.1
LIBGMP_VERSION = 6.1.0
LIBMPFR_VERSION = 3.1.4
LIBMPC_VERSION = 1.0.3
BINUTILS_VERSION = 2.25.1
GCC_VERSION = 5.3.0
GLIBC_VERSION = 2.22

# Make jobs
MJ=-j2

# End of file
