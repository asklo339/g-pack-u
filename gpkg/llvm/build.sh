TERMUX_PKG_HOMEPAGE=https://llvm.org/
TERMUX_PKG_DESCRIPTION="Compiler infrastructure"
TERMUX_PKG_LICENSE="Apache-2.0, NCSA"
TERMUX_PKG_LICENSE_FILE="LICENSE.TXT"
TERMUX_PKG_MAINTAINER="@termux-pacman"
TERMUX_PKG_VERSION=18.1.8
_SOURCE=https://github.com/llvm/llvm-project/releases/download/llvmorg-$TERMUX_PKG_VERSION
TERMUX_PKG_SRCURL=($_SOURCE/llvm-$TERMUX_PKG_VERSION.src.tar.xz
		$_SOURCE/cmake-$TERMUX_PKG_VERSION.src.tar.xz
		$_SOURCE/third-party-$TERMUX_PKG_VERSION.src.tar.xz)
TERMUX_PKG_SHA256=(f68cf90f369bc7d0158ba70d860b0cb34dbc163d6ff0ebc6cfa5e515b9b2e28d
		59badef592dd34893cd319d42b323aaa990b452d05c7180ff20f23ab1b41e837
		b76b810f3d3dc5d08e83c4236cb6e395aa9bd5e3ea861e8c319b216d093db074)
TERMUX_PKG_DEPENDS="libllvm-glibc, perl-glibc"
TERMUX_PKG_BUILD_DEPENDS="binutils-libs-glibc"
TERMUX_PKG_NO_STATICSPLIT=true

termux_step_post_get_source() {
	for i in cmake third-party; do
		rm -fr $TERMUX_TOPDIR/$TERMUX_PKG_NAME/${i}
		mv $TERMUX_PKG_SRCDIR/$i-$TERMUX_PKG_VERSION.src $TERMUX_TOPDIR/$TERMUX_PKG_NAME
		mv $TERMUX_TOPDIR/$TERMUX_PKG_NAME/$i-$TERMUX_PKG_VERSION.src $TERMUX_TOPDIR/$TERMUX_PKG_NAME/$i
	done
}

termux_step_configure() {
	termux_setup_cmake
	termux_setup_ninja

	CFLAGS=${CFLAGS/-g /-g1 }
	CXXFLAGS=${CXXFLAGS/-g /-g1 }

	local LLVM_TARGET_ARCH="X86"
	if [ $TERMUX_ARCH = "arm" ]; then
		LLVM_TARGET_ARCH="ARM"
	elif [ $TERMUX_ARCH = "aarch64" ]; then
		LLVM_TARGET_ARCH="AArch64"
	fi

	cmake ${TERMUX_PKG_SRCDIR} \
		-G Ninja \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_FIND_ROOT_PATH=$TERMUX_PREFIX \
		-DCMAKE_INSTALL_DOCDIR=share/doc \
		-DCMAKE_INSTALL_PREFIX=$TERMUX_PREFIX \
		-DCMAKE_SKIP_RPATH=ON \
		-DLLVM_BINUTILS_INCDIR=$TERMUX_PREFIX/include \
		-DLLVM_BUILD_DOCS=ON \
		-DLLVM_BUILD_LLVM_DYLIB=ON \
		-DLLVM_BUILD_TESTS=ON \
		-DLLVM_ENABLE_BINDINGS=OFF \
		-DLLVM_ENABLE_FFI=ON \
		-DLLVM_ENABLE_RTTI=ON \
		-DLLVM_ENABLE_SPHINX=ON \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DLLVM_HOST_TRIPLE=$TERMUX_HOST_PLATFORM \
		-DCMAKE_LIBRARY_ARCHITECTURE=$TERMUX_HOST_PLATFORM \
		-DCMAKE_SYSTEM_PROCESSOR=$LLVM_TARGET_ARCH \
		-DCMAKE_C_COMPILER=/data/data/com.termux/cgct/aarch64/bin/gcc \
		-DCMAKE_CXX_COMPILER=/data/data/com.termux/cgct/aarch64/bin/g++ \
		-DLLVM_INCLUDE_BENCHMARKS=OFF \
		-DLLVM_INSTALL_UTILS=ON \
		-DLLVM_LINK_LLVM_DYLIB=ON \
		-DLLVM_USE_PERF=ON \
		-DSPHINX_WARNINGS_AS_ERRORS=OFF
}

termux_step_post_make_install() {
	(
		cd ${TERMUX_PKG_SRCDIR}/utils/lit
		python3 setup.py install --prefix=$TERMUX_PREFIX -O1
	)
}
