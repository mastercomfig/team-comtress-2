#!/usr/bin/env bash
set -e  # Stop on error

if [[ ! -v CORES ]]; then
  CORES=`nproc`
fi

if [ ! -f ./thirdparty/gperftools-2.0/.libs/libtcmalloc_minimal.so ]; then
	cd ./thirdparty/gperftools-2.0
  aclocal
  automake --add-missing
	autoconf
	./configure --enable-frame-pointers --host=i386 "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32"
#  sed -i 's/LIBTOOL = $(SHELL) $(top_builddir)\/libtool/LIBTOOL = libtool/' Makefile
  make -j$CORES
	cd ../..
fi

if [ ! -f ./thirdparty/protobuf-2.5.0/src/.libs/libprotobuf.a ]; then
	cd ./thirdparty/protobuf-2.5.0
  aclocal
  automake --add-missing
	autoconf
	chmod u+x autogen.sh
	bash ./configure --host=i386 "CFLAGS=-m32 -D_GLIBCXX_USE_CXX11_ABI=0" "CXXFLAGS=-m32 -D_GLIBCXX_USE_CXX11_ABI=0" "LDFLAGS=-m32" --enable-shared=no
	make -j$CORES
	cd ../..
fi

if [ ! -f ./thirdparty/libedit-3.1/src/.libs/libedit.so ]; then
	cd ./thirdparty/libedit-3.1
  aclocal
  automake --add-missing
	autoconf
	chmod u+x ./configure
	bash ./configure --host=i386 "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32"
	make -j$CORES
	cd ../..
fi

if [ ! -f ./games.mak ]; then
	bash ./creategameprojects.sh
fi

export VALVE_NO_AUTO_P4=1
if [[ $1 == '-v' ]]; then
  make -f games.mak NO_CHROOT=1 MAKE_JOBS=1 MAKE_VERBOSE=1 "${@:2}"
else
  make -f games.mak NO_CHROOT=1 MAKE_JOBS=$CORES "$@"
fi
