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

namespace IDE {
    public class CMakeProject : Project {
        private CMakeParser parser;

        public new static async Project? load (File file) {
            var sources = yield get_cmake_sources (file);
            if (sources.size <= 0) {
                return null;
            }

            var parser = new CMakeParser ();
            foreach (var source in sources) {
                parser.add_cmake_source (source.get_path ());
            }

            var project = new CMakeProject (file.get_path (), parser);
            return project;
        }

        private static async Gee.ArrayList<File> get_cmake_sources (File file) {
            var list = new Gee.ArrayList<File> ();

            try {
                var enumerator = yield file.enumerate_children_async ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS);

                FileInfo? info = null;
                while ((info = enumerator.next_file ()) != null) {
                    if (info.get_file_type () == FileType.DIRECTORY) {
                        var subdir = file.resolve_relative_path (info.get_name ());
                        list.add_all (yield get_cmake_sources (subdir));
                    } else if (info.get_name () == Constants.CMAKE_TARGET) {
                        var subfile = file.resolve_relative_path (info.get_name ());
                        list.add (subfile);
                    }
                }
            } catch (Error e) {
                warning (e.message);
            }

            return list;
        }

        public CMakeProject (string root_path, CMakeParser parser) {
            this.root_path = root_path;
            this.parser = parser;

            update ();
        }

        public override void update () {
            parser.parse ();

            string? project_name = null;
            foreach (var command in parser.get_commands ()) {
                switch (command.name) {
                    case Constants.PROJECT_CMD:
                        var arguments = command.get_arguments ();
                        if (arguments.length == 1) {
                            project_name = arguments[0];
                        }

                        break;
                    case Constants.PKG_CHECK_MODULES_CMD:
                        string[] _check_dependencies = {};
                        var arguments = command.get_arguments ();
                        if (arguments.length > 2) {
                            for (int i = 3; i < arguments.length; i++) {
                                _check_dependencies += arguments[i];
                            }

                            check_dependencies = _check_dependencies;
                        }

                        break;
                    case Constants.VALA_PRECOMIPLE_CMD:
                        string[] _sources = {};
                        string[] _packages = {};
                        string[] _options = {};

                        string current_header = Constants.VALA_PRECOMPILE_HEADERS[0];

                        var arguments = command.get_arguments ();
                        if (arguments.length > 2) {
                            for (int i = 0; i < arguments.length; i++) {
                                if (i < 2) {
                                    continue;
                                }

                                string argument = arguments[i];
                                if (argument in Constants.VALA_PRECOMPILE_HEADERS) {
                                    current_header = argument;
                                    continue;
                                }   

                                if (current_header == Constants.VALA_PRECOMPILE_HEADERS[0]) {
                                    _sources += Path.build_filename (Path.get_dirname (command.filename), argument);
                                } else if (current_header == Constants.VALA_PRECOMPILE_HEADERS[1]) {
                                    _packages += argument;
                                } else if (current_header == Constants.VALA_PRECOMPILE_HEADERS[2]) {
                                    _options += argument;
                                }
                            }

                            sources = _sources;
                            packages = _packages;
                            options = _options;
                        }

                        break;
                    default:
                        break;
                }
            }

            if (project_name != null) {
                name = "%s (%s)".printf (project_name, Path.get_basename (root_path));
            } else {
                name = Path.get_basename (root_path);
            }

            var version_var = parser.find_variable_by_name ("VERSION");
            if (version_var != null) {
                version = version_var.value;
            }

            var exec_name_var = parser.find_variable_by_name ("EXEC_NAME");
            if (exec_name_var != null) {
                exec_name = exec_name_var.value;
            }

            var release_name_var = parser.find_variable_by_name ("RELEASE_NAME");
            if (release_name_var != null) {
                release_name = release_name_var.value;
            }
        }
    }
}