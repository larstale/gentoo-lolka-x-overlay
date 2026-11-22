# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RPM_COMPRESS_TYPE="xz"
inherit desktop rpm xdg

DESCRIPTION="Native desktop client for lolka.app - chat and voice with friends"
HOMEPAGE="https://lolka.app"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
IUSE="gtk"
PROPERTIES="live"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-crypt/mit-krb5
	dev-libs/glib:2
	dev-libs/openssl:=
	elibc_glibc? ( sys-libs/glibc )
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libglvnd[X]
	media-libs/libpulse
	media-libs/libva
	media-libs/mesa
	media-video/pipewire
	media-video/wireplumber
	sys-apps/dbus
	sys-apps/xdg-desktop-portal
	sys-devel/gcc:*
	virtual/zlib:=
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-libs/libxkbcommon[X]
	x11-libs/xcb-util-cursor
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
	x11-misc/xdg-utils
	x11-themes/hicolor-icon-theme
	gtk? ( x11-libs/gtk+:3 )
"
BDEPEND="
	net-misc/curl
"

QA_PREBUILT="
	opt/lolka-x/bin/*
	opt/lolka-x/lib/*
	opt/lolka-x/plugins/*/*
"

src_unpack() {
	local feed_url="https://updates.lolka.app/desktop/linux/latest-linux.yml"
	einfo "Чтение манифеста обновлений: ${feed_url}"

	local manifest
	manifest=$(curl -fsSL "${feed_url}") || die "Не удалось получить latest-linux.yml"

	local latest_ver rpm_url expected_sha512
	latest_ver=$(echo "${manifest}" | awk '/^version:/ {print $2; exit}' | tr -d '\r')
	rpm_url=$(echo "${manifest}" | awk '/url:.*\.x86_64\.rpm/ {print $NF; exit}' | tr -d '\r')
	expected_sha512=$(echo "${manifest}" \
		| awk '/url:.*\.x86_64\.rpm/{found=1; next} found && /sha512:/{print $2; exit}' \
		| tr -d '\r')

	[[ -z "${rpm_url}" ]] && die "Не найдена ссылка на .x86_64.rpm в latest-linux.yml"

	einfo "Актуальная версия: ${latest_ver}"
	einfo "Скачивание: ${rpm_url}"

	local rpm_file="lolka-x-${latest_ver}.rpm"
	curl -fL "${rpm_url}" -o "${WORKDIR}/${rpm_file}" || die "Ошибка скачивания RPM"

	if [[ -n "${expected_sha512}" ]]; then
		local py_cmd="import hashlib, base64, sys; \
			print(base64.b64encode(hashlib.sha512(open(sys.argv[1], 'rb').read()).digest()).decode())"
		local actual_sha512
		actual_sha512=$(python3 -c "${py_cmd}" "${WORKDIR}/${rpm_file}") || die "Ошибка вычисления SHA512"

		if [[ "${actual_sha512}" != "${expected_sha512}" ]]; then
			die "Контрольная сумма SHA512 не совпадает! Ожидалось: ${expected_sha512}, получено: ${actual_sha512}"
		fi
		einfo "Контрольная сумма SHA512 подтверждена."
	fi

	rpm_unpack "./${rpm_file}"
	rm -f "${WORKDIR}/${rpm_file}"
}

src_install() {
	insinto /opt
	doins -r opt/lolka-x

	fperms +x /opt/lolka-x/bin/lolka-x
	find "${ED}/opt/lolka-x" -type f -name "*.so*" -exec chmod +x {} + || die

	dosym ../../opt/lolka-x/bin/lolka-x /usr/bin/lolka-x

	doicon -s 256 opt/lolka-x/share/icons/hicolor/256x256/apps/app.lolka.desktop.qt.png
	domenu opt/lolka-x/share/applications/app.lolka.desktop.qt.desktop
}
