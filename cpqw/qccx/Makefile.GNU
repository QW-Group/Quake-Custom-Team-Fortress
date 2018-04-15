#
# qccx Makefile for Linux and SunOS
#
# GNU Make required
#
# ELF only
#
#	$Id$
#

SV_DIR = .

# to compile qccx as 32bit on 64bit target platform use next:
# for gcc its like: make qccx FORCE32BITFLAGS=-m32
# configure script add FORCE32BITFLAGS=-m32

BASE_CFLAGS=-Wall -pipe -pthread -funsigned-char $(FORCE32BITFLAGS)
WITH_OPTIMIZED_CFLAGS=YES

USE_ASM=-Did386
ifeq ($(WITH_OPTIMIZED_CFLAGS),YES)
ifeq ($(ARCH),x86)
ifneq ($(UNAME),Darwin)
ifneq ($(UNAME),MacOSX)
ASM=$(USE_ASM)
endif
endif
endif
CFLAGS=$(ASM) $(BASE_CFLAGS) -O3 -ffast-math -funroll-loops
else
CFLAGS=$(BASE_CFLAGS) -Wsign-compare -ggdb
endif

LDFLAGS=-lm -lstdc++
ifeq ($(UNAME),Linux)
LDFLAGS+=-ldl
STRIP=-strip
STRIP_FLAGS=--strip-unneeded --remove-section=.comment qccx
else
ifeq ($(UNAME),SunOS)
LDFLAGS+= -lsocket -lnsl
CFLAGS+= -DBSD_COMP
endif
endif

ifeq ($(CC_BASEVERSION),4) # if gcc4 then build universal binary
ifeq ($(UNAME),Darwin)
CFLAGS+= -arch ppc -arch i386
endif
ifeq ($(UNAME),MacOSX)
CFLAGS+= -arch ppc -arch i386
endif
endif

#############################################################################
# SERVER
#############################################################################

SV_OBJS = \
		$(SV_DIR)/cmdlib.cpp  hash.cpp  pr_comp.cpp  pr_lex.cpp  qcc.cpp\

ifeq ($(USE_ASM),$(ASM))
SV_ASM_OBJS = \

endif

#############################################################################
# SETUP AND BUILD
#############################################################################

.cpp.o :
	$(CC) $(CFLAGS) -c $< -o $@

.s.o :
	$(CC) $(CFLAGS) -DELF -x assembler-with-cpp -c $< -o $@

all : qccx
	$(STRIP) $(STRIP_FLAGS)

qccx : $(SV_OBJS) $(SV_ASM_OBJS)
	$(CC) $(CFLAGS) -o qccx $^ $(LDFLAGS)

clean : 
	-rm -f $(SV_DIR)/core $(SV_DIR)/*.o cppreqcc
