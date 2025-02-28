TERMUX_PKG_HOMEPAGE=https://gcc.gnu.org/
TERMUX_PKG_DESCRIPTION="Runtime libraries shipped by GCC"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux-pacman"
TERMUX_PKG_VERSION=14.1.0
TERMUX_PKG_SRCURL=https://ftp.gnu.org/gnu/gcc/gcc-$TERMUX_PKG_VERSION/gcc-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=e283c654987afe3de9d8080bc0bd79534b5ca0d681a73a11ff2b5d3767426840
TERMUX_PKG_DEPENDS="glibc"
TERMUX_PKG_BUILD_DEPENDS="doxygen-glibc"
TERMUX_PKG_BREAKS="gcc-glibc-libs-dev"
TERMUX_PKG_REPLACES="gcc-glibc-libs-dev"
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_SEPARATE_SUB_DEPENDS=true
TERMUX_PKG_ONLY_INSTALLING=true

termux_step_pre_configure() {
	sed -i 's@\./fixinc\.sh@-c true@' ${TERMUX_PKG_SRCDIR}/gcc/Makefile.in
	sed -i '/m64=/s/lib64/lib/' ${TERMUX_PKG_SRCDIR}/gcc/config/i386/t-linux64
	sed -i '/lp64=/s/lib64/lib/' ${TERMUX_PKG_SRCDIR}/gcc/config/aarch64/t-aarch64-linux
	CFLAGS=${CFLAGS/-Werror=format-security/}
        LDFLAGS="-L/data/data/com.termux/cgct/aarch64/lib"
	CXXFLAGS=${CXXFLAGS/-Werror=format-security/}
	CFLAGS+=" -I${TERMUX_PREFIX}/include -L${TERMUX_PREFIX}/lib"
	CXXFLAGS+=" -I${TERMUX_PREFIX}/include -L${TERMUX_PREFIX}/lib"
}

termux_step_configure() {
	local CONFIGFLAG=""
	case $TERMUX_ARCH in
		"aarch64") CONFIGFLAG="--with-arch=armv8-a --enable-fix-cortex-a53-835769 --enable-fix-cortex-a53-843419";;
		"arm") CONFIGFLAG="--with-arch=armv7-a --with-float=hard --with-fpu=neon";;
		"x86_64") CONFIGFLAG="--with-arch=x86-64";;
		"i686") CONFIGFLAG="--with-arch=i686";;
	esac

	${TERMUX_PKG_SRCDIR}/configure \
		--host=$TERMUX_HOST_PLATFORM \
		--build=$TERMUX_HOST_PLATFORM \
		--target=$TERMUX_HOST_PLATFORM \
		--prefix=$TERMUX_PREFIX \
		--libdir=$TERMUX_PREFIX/lib \
		--libexecdir=$TERMUX_PREFIX/lib \
		--mandir=$TERMUX_PREFIX/share/man \
		--infodir=$TERMUX_PREFIX/share/info \
		--with-bugurl=https://github.com/termux-pacman/glibc-packages/issues \
		--with-gmp=$TERMUX_PREFIX \
		--with-mpfr=$TERMUX_PREFIX \
		--with-mpc=$TERMUX_PREFIX \
		$CONFIGFLAG \
		--disable-multilib \
		--disable-bootstrap \
		--disable-nls \
		--enable-default-pie \
		--enable-languages=c,c++,fortran \
		--with-system-zlib \
		--enable-__cxa_atexit \
		--enable-linker-build-id \
		--enable-plugin \
		--with-linker-hash-style=gnu \
		--enable-gnu-indirect-function \
		--disable-werror \
		--disable-checking \
		--disable-static \
		--enable-host-shared \
		--disable-libssp \
		--disable-libstdcxx-pch \
		LD_FOR_TARGET=$TERMUX_PREFIX/bin/ld
}

termux_step_make() {
	make
}

termux_step_make_install() {
	local _libdir=$TERMUX_PREFIX/lib/gcc/$TERMUX_HOST_PLATFORM/${TERMUX_PKG_VERSION%%+*}

	# --- gcc-libs ---
	make -C $TERMUX_HOST_PLATFORM/libgcc install-shared

	for lib in libatomic \
		libgfortran \
		libgomp \
		libitm \
		libquadmath \
		libsanitizer/{a,l,ub}san \
		libstdc++-v3/src \
		libvtv; do
		make -C $TERMUX_HOST_PLATFORM/$lib install-toolexeclibLTLIBRARIES
	done

	if [ "$TERMUX_ARCH" = "x86_64" ] || [ "$TERMUX_ARCH" = "aarch64" ]; then
		make -C $TERMUX_HOST_PLATFORM/libsanitizer/tsan install-toolexeclibLTLIBRARIES
	fi

	make -C $TERMUX_HOST_PLATFORM/libstdc++-v3/po install

	for lib in libgomp \
		libitm \
		libquadmath; do
		make -C $TERMUX_HOST_PLATFORM/$lib install-info
	done

	# --- gcc ---
	make -C gcc install-driver install-cpp install-gcc-ar \
		c++.install-common install-headers install-plugin install-lto-wrapper

	install -m755 -t $TERMUX_PREFIX/bin/ gcc/gcov{,-tool}
	install -m755 -t ${_libdir}/ gcc/{cc1,cc1plus,collect2,lto1}

	make -C $TERMUX_HOST_PLATFORM/libgcc install

	make -C $TERMUX_HOST_PLATFORM/libstdc++-v3/src install
	make -C $TERMUX_HOST_PLATFORM/libstdc++-v3/include install
	make -C $TERMUX_HOST_PLATFORM/libstdc++-v3/libsupc++ install
	make -C $TERMUX_HOST_PLATFORM/libstdc++-v3/python install

	make install-libcc1
	if [ -f $TERMUX_PREFIX/lib/libstdc++.so.6.*-gdb.py ]; then
		install -d $TERMUX_PREFIX/share/gdb/auto-load/usr/lib
		mv $TERMUX_PREFIX/lib/libstdc++.so.6.*-gdb.py \
			$TERMUX_PREFIX/share/gdb/auto-load/usr/lib/
	fi

	make install-fixincludes
	make -C gcc install-mkheaders

	make -C lto-plugin install
	install -dm755 $TERMUX_PREFIX/lib/bfd-plugins/
	ln -s /${_libdir}/liblto_plugin.so \
		$TERMUX_PREFIX/lib/bfd-plugins/

	make -C $TERMUX_HOST_PLATFORM/libgomp install-nodist_{libsubinclude,toolexeclib}HEADERS
	make -C $TERMUX_HOST_PLATFORM/libitm install-nodist_toolexeclibHEADERS
	make -C $TERMUX_HOST_PLATFORM/libquadmath install-nodist_libsubincludeHEADERS
	make -C $TERMUX_HOST_PLATFORM/libsanitizer install-nodist_{saninclude,toolexeclib}HEADERS
	make -C $TERMUX_HOST_PLATFORM/libsanitizer/asan install-nodist_toolexeclibHEADERS
	if [ "$TERMUX_ARCH" = "aarch64" ]; then
		make -C $TERMUX_HOST_PLATFORM/libsanitizer/tsan install-nodist_toolexeclibHEADERS
	fi
	make -C $TERMUX_HOST_PLATFORM/libsanitizer/lsan install-nodist_toolexeclibHEADERS

	make -C gcc install-man install-info

	make -C libcpp install
	make -C gcc install-po

	ln -s gcc $TERMUX_PREFIX/bin/cc

	install -Dm755 $TERMUX_PKG_BUILDER_DIR/c89 $TERMUX_PREFIX/bin/c89
	install -Dm755 $TERMUX_PKG_BUILDER_DIR/c99 $TERMUX_PREFIX/bin/c99

	python -m compileall $TERMUX_PREFIX/share/gcc-${TERMUX_PKG_VERSION%%+*}/
	python -O -m compileall $TERMUX_PREFIX/share/gcc-${TERMUX_PKG_VERSION%%+*}/

	# --- gcc-fortran ---

	make -C $TERMUX_HOST_PLATFORM/libgfortran install-cafexeclibLTLIBRARIES \
		install-{toolexeclibDATA,nodist_fincludeHEADERS,gfor_cHEADERS}
	make -C $TERMUX_HOST_PLATFORM/libgomp install-nodist_fincludeHEADERS
	make -C gcc fortran.install-{common,man,info}
	install -Dm755 gcc/f951 ${_libdir}/f951

	ln -s gfortran $TERMUX_PREFIX/bin/f95

	if [ -d $TERMUX_PREFIX/lib64 ]; then
		mv $TERMUX_PREFIX/lib64/* $TERMUX_PREFIX/lib
		rm -fr $TERMUX_PREFIX/lib64
	fi

	if [ -d $TERMUX_PREFIX/lib32 ]; then
		mv $TERMUX_PREFIX/lib32/* $TERMUX_PREFIX/lib
		rm -fr $TERMUX_PREFIX/lib32
	fi
}
