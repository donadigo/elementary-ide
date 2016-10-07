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
    public enum ProjectType {
        UNKNOWN = 0,
        VALA_APPLICATION,
        VALA_LIBRARY
    }

    public class Project : Object {
        private const string PROJECT_KEY = "elementary-ide-project";
        private const string METADATA_EXTENSION = "eide";
        private const string NAME_KEY = "name";
        private const string DISPLAY_NAME_KEY = "display-name";
        private const string TYPE_KEY = "type";
        private const string ROOT_PATH_KEY = "root-path";

        public string name { get; set; }
        public string display_name { get; set; }
        public string root_path { get; set; }
        public ProjectType project_type { get; set; }
        public EditorView editor_view { get; set; }

        public static bool get_is_metadata_file (File file) {
            if (!file.query_exists ()) {
                return false;
            }

            return Utils.get_extension (file) == METADATA_EXTENSION;
        }

        public static Project? load (File file) {
            if (get_is_metadata_file (file)) {
                return load_from_metadata (file);
            }

            return load_from_generic (file);
        }

        private static Project? load_from_metadata (File file) {
            var key = new KeyFile ();
            try {
                if (!key.load_from_file (file.get_path (), KeyFileFlags.NONE)) {
                    return null;
                }

                string name = key.get_string (PROJECT_KEY, NAME_KEY);
                string display_name = key.get_string (PROJECT_KEY, DISPLAY_NAME_KEY);
                int type = key.get_integer (PROJECT_KEY, TYPE_KEY);

                string? root_path = key.get_string (PROJECT_KEY, ROOT_PATH_KEY);
                if (root_path == null || root_path == "") {
                    var parent = file.get_parent ();
                    if (parent != null) {
                        root_path = parent.get_path ();
                    } else {
                        root_path = "";
                    }
                }


                return new Project ((ProjectType)type, name, display_name, root_path);
            } catch (Error e) {
                warning (e.message);
            }

            return null;
        }

        private static Project? load_from_generic (File file) {
            string root_path = "";
            string name = file.get_basename ();
            var parent = file.get_parent ();

            if (FileUtils.test (file.get_path (), FileTest.IS_REGULAR) && parent != null) {
                root_path = parent.get_path ();
            } else {
                root_path = file.get_path ();
            }

            return new Project (ProjectType.UNKNOWN, name, "", root_path);
        }

        public Project (ProjectType project_type, string name, string display_name, string root_path) {
            this.project_type = project_type;
            this.name = name;
            this.display_name = display_name;
            this.root_path = root_path;
            this.editor_view = new EditorView.from_project (this);
        }
    }
}