TERMUX_PKG_HOMEPAGE=https://dev.lovelyhq.com/libburnia
TERMUX_PKG_DESCRIPTION="Library to pack up hard disk files and directories into a ISO 9660 disk image"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=1.5.6.pl01
TERMUX_PKG_SRCURL=https://files.libburnia-project.org/releases/libisofs-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=ac1fd338d641744ca1fb1567917188b79bc8c2506832dd56885fec98656b9f25
TERMUX_PKG_DEPENDS="libiconv, zlib"
TERMUX_PKG_BREAKS="libisofs-dev"
TERMUX_PKG_REPLACES="libisofs-dev"
TERMUX_PKG_BUILD_IN_SRC=true
