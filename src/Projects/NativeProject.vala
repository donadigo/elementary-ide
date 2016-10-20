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
    public class NativeProject : Project {
        private KeyFile key;
        private string target;

        public new static async Project? load (File file) {
            string target = Path.build_filename (file.get_path (), Constants.NATIVE_TARGET);
            if (!FileUtils.test (target, FileTest.EXISTS)) {
                return null;
            }

            var project = new NativeProject (target);
            return project;
        }

        construct {
            get_can_save = true;
            
            key = new KeyFile ();
            key.set_list_separator (';');
        }

        public NativeProject (string target) {
            this.target = target;
            root_path = Path.get_dirname (target);

            update ();
        }

        public override void update () {
            try {
                key.load_from_file (target, KeyFileFlags.NONE);

                if (key.has_key (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_NAME)) {
                    name = key.get_string (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_NAME);
                }

                if (key.has_key (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_VERSION)) {
                    version = key.get_string (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_VERSION);
                }

                if (key.has_key (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_EXEC_NAME)) {
                    exec_name = key.get_string (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_EXEC_NAME);
                }

                if (key.has_key (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_RELEASE_NAME)) {
                    release_name = key.get_string (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_RELEASE_NAME);
                }

                if (key.has_key (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_PACKAGES)) {
                    string[] packages_list = key.get_string_list (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_PACKAGES);
                    foreach (string package in packages_list) {
                        packages.add (package);
                    }
                }

                if (key.has_key (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_SOURCES)) {
                    string[] sources_list = key.get_string_list (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_SOURCES);
                    foreach (string source in sources_list) {
                        sources.add (source);
                    }
                }

                if (key.has_key (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_OPTIONS)) {
                    string[] options_list = key.get_string_list (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_OPTIONS);
                    foreach (string option in options_list) {
                        options.add (option);
                    }
                }

                if (key.has_key (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROEJCT_CHECK_DEPS)) {
                    string[] check_dependencies_list = key.get_string_list (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROEJCT_CHECK_DEPS);
                    foreach (string dependency in check_dependencies_list) {
                        check_dependencies.add (dependency);
                    }
                }

                if (key.has_key (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_PROJECT_TYPE)) {
                    project_type = (ProjectType)key.get_integer (Constants.NATIVE_PROJECT_GROUP, Constants.NATIVE_PROJECT_PROJECT_TYPE);
                }
            } catch (Error e) {
                warning (e.message);
            }
        }
    }
}