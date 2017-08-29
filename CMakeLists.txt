project (elementary-ide)

cmake_minimum_required (VERSION 2.8)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/${CMAKE_PROJECT_NAME}")
set (GETTEXT_PACKAGE ${CMAKE_PROJECT_NAME})
set (EXEC_NAME ${CMAKE_PROJECT_NAME})
set (VERSION "0.1")
set (DOLLAR "$")

add_definitions (-DGETTEXT_PACKAGE="${GETTEXT_PACKAGE}")
add_definitions (-w)

find_package (Vala REQUIRED)
string(REGEX REPLACE ".(\\*|[0-9])$" "" LIBVALA_VERSION "${VALA_VERSION}")
include (ValaVersion)
ensure_vala_version ("0.30" MINIMUM)

find_package (PkgConfig)
pkg_check_modules (DEPS REQUIRED granite libvala-${LIBVALA_VERSION} gtksourceview-3.0 vte-2.91 gee-0.8 valadoc-1.0 json-glib-1.0)
add_definitions (${DEPS_CFLAGS})
link_directories (${DEPS_LIBRARY_DIRS})


include (ValaPrecompile)

add_subdirectory (src)
add_subdirectory (schemas)
add_subdirectory (data)
