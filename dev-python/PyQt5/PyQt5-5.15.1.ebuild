# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
inherit multibuild python-r1 qmake-utils

DESCRIPTION="Python bindings for the Qt framework"
HOMEPAGE="https://www.riverbankcomputing.com/software/pyqt/intro"

MY_P=${PN}-${PV/_pre/.dev}
if [[ ${PV} == *_pre* ]]; then
	SRC_URI="https://dev.gentoo.org/~pesa/distfiles/${MY_P}.tar.gz"
else
	SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 x86"

# TODO: QtNfc, QtQuick3D, QtRemoteObjects, QtTextToSpeech
IUSE="bluetooth dbus debug declarative designer examples gles2-only gui help location
	multimedia network networkauth opengl positioning printsupport sensors serialport
	sql +ssl svg testlib webchannel webkit websockets widgets x11extras xmlpatterns"

# The requirements below were extracted from configure.py
# and from the output of 'grep -r "%Import " "${S}"/sip'
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	bluetooth? ( gui )
	declarative? ( gui network )
	designer? ( widgets )
	help? ( gui widgets )
	location? ( positioning )
	multimedia? ( gui network )
	networkauth? ( network )
	opengl? ( gui widgets )
	positioning? ( gui )
	printsupport? ( gui widgets )
	sensors? ( gui )
	serialport? ( gui )
	sql? ( widgets )
	svg? ( gui widgets )
	testlib? ( widgets )
	webchannel? ( network )
	webkit? ( gui network printsupport widgets )
	websockets? ( network )
	widgets? ( gui )
	xmlpatterns? ( network )
"

# Minimal supported version of Qt.
QT_PV="5.14:5"

RDEPEND="${PYTHON_DEPS}
	>=dev-python/PyQt5-sip-4.19.23:=[${PYTHON_USEDEP}]
	>=dev-qt/qtcore-${QT_PV}
	>=dev-qt/qtxml-${QT_PV}
	bluetooth? ( >=dev-qt/qtbluetooth-${QT_PV} )
	dbus? (
		dev-python/dbus-python[${PYTHON_USEDEP}]
		>=dev-qt/qtdbus-${QT_PV}
	)
	declarative? ( >=dev-qt/qtdeclarative-${QT_PV}[widgets?] )
	designer? ( >=dev-qt/designer-${QT_PV} )
	gui? ( >=dev-qt/qtgui-${QT_PV}[gles2-only=] )
	help? ( >=dev-qt/qthelp-${QT_PV} )
	location? ( >=dev-qt/qtlocation-${QT_PV} )
	multimedia? ( >=dev-qt/qtmultimedia-${QT_PV}[widgets?] )
	network? ( >=dev-qt/qtnetwork-${QT_PV}[ssl=] )
	networkauth? ( >=dev-qt/qtnetworkauth-${QT_PV} )
	opengl? ( >=dev-qt/qtopengl-${QT_PV} )
	positioning? ( >=dev-qt/qtpositioning-${QT_PV} )
	printsupport? ( >=dev-qt/qtprintsupport-${QT_PV} )
	sensors? ( >=dev-qt/qtsensors-${QT_PV} )
	serialport? ( >=dev-qt/qtserialport-${QT_PV} )
	sql? ( >=dev-qt/qtsql-${QT_PV} )
	svg? ( >=dev-qt/qtsvg-${QT_PV} )
	testlib? ( >=dev-qt/qttest-${QT_PV} )
	webchannel? ( >=dev-qt/qtwebchannel-${QT_PV} )
	webkit? ( dev-qt/qtwebkit:5[printsupport] )
	websockets? ( >=dev-qt/qtwebsockets-${QT_PV} )
	widgets? ( >=dev-qt/qtwidgets-${QT_PV} )
	x11extras? ( >=dev-qt/qtx11extras-${QT_PV} )
	xmlpatterns? ( >=dev-qt/qtxmlpatterns-${QT_PV} )
"
DEPEND="${RDEPEND}
	>=dev-python/sip-4.19.23[${PYTHON_USEDEP}]
	dbus? ( virtual/pkgconfig )
"

S=${WORKDIR}/${MY_P}

pyqt_use_enable() {
	use "$1" || return

	if [[ $# -eq 1 ]]; then
		echo --enable=Qt$(tr 'a-z' 'A-Z' <<< ${1:0:1})${1:1}
	else
		shift
		echo ${@/#/--enable=}
	fi
}

src_configure() {
	configuration() {
		local myconf=(
			"${PYTHON}"
			"${S}"/configure.py
			$(usex debug '--debug --qml-debug --trace' '')
			--verbose
			--confirm-license
			--qmake="$(qt5_get_bindir)"/qmake
			--bindir="${EPREFIX}/usr/bin"
			--qsci-api
			--enable=QtCore
			--enable=QtXml
			$(pyqt_use_enable bluetooth)
			$(pyqt_use_enable dbus QtDBus)
			$(usex dbus '' --no-python-dbus)
			$(pyqt_use_enable declarative QtQml QtQuick $(usex widgets QtQuickWidgets ''))
			$(usex declarative '' --no-qml-plugin)
			$(pyqt_use_enable designer)
			$(usex designer '' --no-designer-plugin)
			$(usex gles2-only '--disable-feature=PyQt_Desktop_OpenGL' '')
			$(pyqt_use_enable gui)
			$(pyqt_use_enable gui $(use gles2-only && echo _QOpenGLFunctions_ES2 || echo _QOpenGLFunctions_{2_0,2_1,4_1_Core}))
			$(pyqt_use_enable help)
			$(pyqt_use_enable location)
			$(pyqt_use_enable multimedia QtMultimedia $(usex widgets QtMultimediaWidgets ''))
			$(pyqt_use_enable network)
			$(pyqt_use_enable networkauth QtNetworkAuth)
			$(pyqt_use_enable opengl QtOpenGL)
			$(pyqt_use_enable positioning)
			$(pyqt_use_enable printsupport QtPrintSupport)
			$(pyqt_use_enable sensors)
			$(pyqt_use_enable serialport QtSerialPort)
			$(pyqt_use_enable sql)
			$(usex ssl '' '--disable-feature=PyQt_SSL')
			$(pyqt_use_enable svg)
			$(pyqt_use_enable testlib QtTest)
			$(pyqt_use_enable webchannel QtWebChannel)
			$(pyqt_use_enable webkit QtWebKit QtWebKitWidgets)
			$(pyqt_use_enable websockets QtWebSockets)
			$(pyqt_use_enable widgets)
			$(pyqt_use_enable x11extras QtX11Extras)
			$(pyqt_use_enable xmlpatterns QtXmlPatterns)
		)
		echo "${myconf[@]}"
		"${myconf[@]}" || die

		# Run eqmake to respect toolchain and build flags
		eqmake5 -recursive ${PN}.pro
	}
	python_foreach_impl run_in_build_dir configuration
}

src_compile() {
	python_foreach_impl run_in_build_dir default
}

src_install() {
	installation() {
		local tmp_root=${D}/${PN}_tmp_root
		# parallel install fails because mk_distinfo.py runs too early
		emake -j1 INSTALL_ROOT="${tmp_root}" install

		local bin_dir=${tmp_root}${EPREFIX}/usr/bin
		local exe
		for exe in pylupdate5 pyrcc5 pyuic5; do
			python_doexe "${bin_dir}/${exe}"
			rm "${bin_dir}/${exe}" || die
		done

		local uic_dir=${tmp_root}$(python_get_sitedir)/${PN}/uic
		rm -r "${uic_dir}"/port_v2 || die

		multibuild_merge_root "${tmp_root}" "${D}"
		python_optimize
	}
	python_foreach_impl run_in_build_dir installation

	einstalldocs

	if use examples; then
		dodoc -r examples
	fi
}
