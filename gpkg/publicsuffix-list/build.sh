TERMUX_PKG_HOMEPAGE=https://github.com/publicsuffix/list
TERMUX_PKG_DESCRIPTION="Cross-vendor public domain suffix database"
TERMUX_PKG_LICENSE="MPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-pacman"
_COMMIT=9094af5c6cb260e69137c043c01be18fee01a540
TERMUX_PKG_VERSION="2024.03.06"
TERMUX_PKG_SRCURL=git+https://github.com/publicsuffix/list
TERMUX_PKG_SHA256=6d9f7108184522fbf7b8aef9569354068ad7693991e4520d6506407c681887ce
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout $_COMMIT

	local version="$(git log -1 --format=%cs | sed 's/-/./g')"
	if [ "$version" != "$TERMUX_PKG_VERSION" ]; then
		echo -n "ERROR: The specified version \"$TERMUX_PKG_VERSION\""
		echo " is different from what is expected to be: \"$version\""
		return 1
	fi

	local s=$(find . -type f ! -path '*/.git/*' -print0 | xargs -0 sha256sum | LC_ALL=C sort | sha256sum)
	if [[ "${s}" != "${TERMUX_PKG_SHA256}  "* ]]; then
		termux_error_exit "Checksum mismatch for source files."
	fi
}

termux_step_make() {
	return
}

termux_step_make_install() {
	install -Dm 644 public_suffix_list.dat tests/test_psl.txt -t "$TERMUX_PREFIX/share/publicsuffix"
	ln -s public_suffix_list.dat "$TERMUX_PREFIX/share/publicsuffix/effective_tld_names.dat"
}
