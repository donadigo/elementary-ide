/*-
 * Copyright (c) 2015-2016 Adam Bieńkowski
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Adam Bieńkowski <donadigos159@gmail.com>
 */

namespace IDE.Constants {
    // TODO: fetch this from CMake
    public const string APP_NAME = "elementary IDE";
    public const string EXEC_NAME = "elementary-ide";

    public const string WELCOME_VIEW_NAME = "welcome";
    public const string EDITOR_VIEW_NAME = "editor-view";
    public const string REPORT_VIEW_NAME = "report-view";
    public const string TERMINAL_VIEW_NAME = "terminal-view";

    public const string NO_DOCUMENTS_VIEW_NAME = "no-documents";
    public const string NOTEBOOK_VIEW_NAME = "notebook";

    public const string NATIVE_TARGET = ".elementary-ide.proj";
    public const string CMAKE_TARGET = "CMakeLists.txt";

    public const string NATIVE_PROJECT_GROUP = "elementary-ide-project";
    public const string NATIVE_PROJECT_NAME = "name";
    public const string NATIVE_PROJECT_VERSION = "version";
    public const string NATIVE_PROJECT_EXEC_NAME = "exec-name";
    public const string NATIVE_PROJECT_RELEASE_NAME = "release-name";
    public const string NATIVE_PROJECT_PACKAGES = "packages";
    public const string NATIVE_PROJECT_SOURCES = "sources";
    public const string NATIVE_PROJECT_OPTIONS = "options";
    public const string NATIVE_PROEJCT_CHECK_DEPS = "check-dependencies";
    public const string NATIVE_PROJECT_PROJECT_TYPE = "project-type";

    public const string PROJECT_CMD = "project";
    public const string PKG_CHECK_MODULES_CMD = "pkg_check_modules";
    public const string VALA_PRECOMPILE_CMD = "vala_precompile";
    public const string ADD_LIBRARY_CMD = "add_library";
    public const string ADD_EXECUTABLE_CMD = "add_executable";
    public const string SET_CMD = "set";
    public const string ADD_SUBDIRECTORY_CMD = "add_subdirectory";
    public const string[] VALA_PRECOMPILE_HEADERS =  { "SOURCES",
                                                    "PACKAGES",
                                                    "OPTIONS",
                                                    "DIRECTORY",
                                                    "PACKAGES",
                                                    "GENERATE_HEADER",
                                                    "DEFINITIONS",
                                                    "CUSTOM_VAPIS" };
}