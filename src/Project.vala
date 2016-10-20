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
        public string name { get; set; default = ""; }
        public string root_path { get; set; default = ""; }
        public string version { get; set; default = ""; }
        public string exec_name { get; set; default = ""; }
        public string build_exec_name { get; set; default = ""; }
        public string release_name { get; set; default = ""; }
        public Gee.ArrayList<string> packages { public get; private set; }
        public Gee.ArrayList<string> sources { public get; private set; }
        public Gee.ArrayList<string> options { public get; private set; }
        public Gee.ArrayList<string> check_dependencies { public get; private set; }
        public ProjectType project_type { get; set; default = ProjectType.UNKNOWN; }
        public bool get_can_save { public get; protected set; default = false; }

        public static bool check (File file) {
            return true;
        }

        public static async Project? load (File file) {
            var native_project = yield NativeProject.load (file);
            if (native_project != null) {
                return native_project;
            }

            var cmake_project = yield CMakeProject.load (file);
            if (cmake_project != null) {
                return cmake_project;
            }

            return yield GenericProject.load (file);
        }

        construct {
            packages = new Gee.ArrayList<string> ();
            sources = new Gee.ArrayList<string> ();
            options = new Gee.ArrayList<string> ();
            check_dependencies = new Gee.ArrayList<string> ();
        }

        public string get_title () {
            string basename = Path.get_basename (root_path);
            if (name != "" && name != basename) {
                return "%s (%s)".printf (name, basename);
            }

            return basename;
        }

        public virtual void save () {

        }

        public virtual void update () {
            
        }
    }
}