TERMUX_PKG_HOMEPAGE=https://xorg.freedesktop.org/
TERMUX_PKG_DESCRIPTION="X11 miscellaneous micro-utility library"
# Licenses: MIT, HPND, ISC
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="COPYING"
TERMUX_PKG_MAINTAINER="@termux-pacman"
TERMUX_PKG_VERSION=1.2.1
TERMUX_PKG_SRCURL=https://xorg.freedesktop.org/releases/individual/lib/libXmu-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=fcb27793248a39e5fcc5b9c4aec40cc0734b3ca76aac3d7d1c264e7f7e14e8b2
TERMUX_PKG_DEPENDS="libxext-glibc, libxt-glibc"
TERMUX_PKG_BUILD_DEPENDS="xorg-util-macros-glibc"
