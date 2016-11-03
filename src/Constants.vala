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
    // Application constants
    public const string APP_NAME = "elementary IDE";
    public const string EXEC_NAME = "elementary-ide";

    // ID constants
    public const string WELCOME_VIEW_NAME = "welcome";
    public const string EDITOR_VIEW_NAME = "editor-view";
    public const string REPORT_VIEW_NAME = "report-view";
    public const string TERMINAL_VIEW_NAME = "terminal-view";
    public const string NO_DOCUMENTS_VIEW_NAME = "no-documents";
    public const string NOTEBOOK_VIEW_NAME = "notebook";
    public const string FILE_SIDEBAR_VIEW_NAME = "file-sidebar";
    public const string FILE_SEARCH_VIEW_NAME = "file-search-view";
    public const string FILE_SEARCH_VIEW_SPINNER_NAME = "file-search-view-spinner";
    public const string FILE_SEARCH_NO_RESULTS_VIEW_NAME = "file-search-view-no-results";

    // Project targets constants
    public const string NATIVE_TARGET = ".elementary-ide.proj";
    public const string CMAKE_TARGET = "CMakeLists.txt";

    // Native project constants
    public const string NATIVE_PROJECT_NAME = "name";
    public const string NATIVE_PROJECT_PROJECT_DIRECTORY = "projectDirectory";
    public const string NATIVE_PROJECT_PROJECT_TYPE = "projectType";
    public const string NATIVE_PROJECT_VERSION = "version";
    public const string NATIVE_PROJECT_EXECUTABLE_PATH = "executablePath";
    public const string NATIVE_PROJECT_PACKAGES = "packages";
    public const string NATIVE_PROJECT_SOURCES = "sources";
    public const string NATIVE_PROEJCT_DEPENDENCIES = "dependencies";
    public const string NATIVE_PROJECT_VALA_OPTIONS = "valaOptions";

    // Native project build system constants
    public const string NATIVE_PROJECT_BUILD_SYSTEM = "buildSystem";
    public const string NATIVE_PROJECT_BS_CLEAN_CMD = "cleanCmd";
    public const string NATIVE_PROJECT_BS_PREBUILD_CMD = "prebuildCmd";
    public const string NATIVE_PROJECT_BS_BUILD_CMD = "buildCmd";
    public const string NATIVE_PROJECT_BS_INTALL_CMD = "installCmd";
    public const string NATIVE_PROJECT_BS_RUN_CMD = "runCmd";

    // Native project debug system constants
    public const string NATIVE_PROJECT_DEBUG_SYSTEM = "debugSystem";
    public const string NATIVE_PROJECT_DS_TEMPLATE_ENVIRONMENT_VARIABLES = "environmentVariables";
    public const string NATIVE_PROJECT_DS_TEMPLATE_RUN_ARGUMENTS = "runArguments";

    // CMake commands constants
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