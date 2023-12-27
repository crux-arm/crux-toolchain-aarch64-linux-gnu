#
# vars.mk
#

HOST = $(shell echo $$MACHTYPE | sed "s/$$(echo $$MACHTYPE | cut -d- -f2)/cross/")
TARGET = aarch64-crux-linux-gnueabi

TOPDIR  = $(shell pwd)
CLFS = $(TOPDIR)/clfs
CROSSTOOLS = $(TOPDIR)/crosstools
WORK = $(TOPDIR)/work

KERNEL_HEADERS_VERSION = 4.9.5
LIBGMP_VERSION = 6.1.2
LIBMPFR_VERSION = 3.1.5
LIBMPC_VERSION = 1.0.3
BINUTILS_VERSION = 2.27
GCC_VERSION = 6.3.0
GLIBC_VERSION = 2.24

# Make jobs
MJ=-j2

# End of file
