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
        public string executable_path { get; set; default = ""; }
        public string release_name { get; set; default = ""; }
        public Gee.ArrayList<string> packages { public get; private set; }
        public Gee.ArrayList<string> sources { public get; private set; }
        public Gee.ArrayList<string> vala_options { public get; private set; }
        public Gee.ArrayList<string> dependencies { public get; private set; }
        public ProjectType project_type { get; set; default = ProjectType.UNKNOWN; }
        public BuildSystem build_system { public get; construct; }
        public DebugSystem debug_system { public get; construct; }

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
            vala_options = new Gee.ArrayList<string> ();
            dependencies = new Gee.ArrayList<string> ();

            build_system = new BuildSystem ();
            debug_system = new DebugSystem ();
        }

        public string get_title () {
            string basename = Path.get_basename (root_path);
            if (name != "" && name != basename) {
                return "%s (%s)".printf (name, basename);
            }

            return basename;
        }

        public virtual void save () {
            var builder = new Json.Builder ();
            builder.begin_object ();
            builder.set_member_name (Constants.NATIVE_PROJECT_NAME);
            builder.add_string_value (name);

            builder.set_member_name (Constants.NATIVE_PROJECT_PROJECT_DIRECTORY);
            builder.add_string_value (root_path);

            builder.set_member_name (Constants.NATIVE_PROJECT_PROJECT_TYPE);
            builder.add_int_value ((int)project_type);

            builder.set_member_name (Constants.NATIVE_PROJECT_VERSION);
            builder.add_string_value (version);

            builder.set_member_name (Constants.NATIVE_PROJECT_EXECUTABLE_PATH);
            builder.add_string_value (executable_path);

            var array = new Json.Array ();
            foreach (string package in packages) {
                array.add_string_element (package);   
            }

            var node = new Json.Node (Json.NodeType.ARRAY);
            node.set_array (array);

            builder.set_member_name (Constants.NATIVE_PROJECT_PACKAGES);
            builder.add_value (node);

            array = new Json.Array ();
            foreach (string source in sources) {
                array.add_string_element (source);
            }

            node.set_array (array);

            builder.set_member_name (Constants.NATIVE_PROJECT_SOURCES);
            builder.add_value (node);

            array = new Json.Array ();
            foreach (string dep in dependencies) {
                array.add_string_element (dep);
            }

            node.set_array (array);

            builder.set_member_name (Constants.NATIVE_PROEJCT_DEPENDENCIES);
            builder.add_value (node);

            array = new Json.Array ();
            foreach (string vo in vala_options) {
                array.add_string_element (vo);
            }

            node.set_array (array);

            builder.set_member_name (Constants.NATIVE_PROJECT_VALA_OPTIONS);
            builder.add_value (node);

            write_build_system (builder);
            write_debug_system (builder);

            builder.end_object ();

            var generator = new Json.Generator ();
            generator.pretty = true;
            generator.root = builder.get_root ();

            string target = Path.build_filename (root_path, Constants.NATIVE_TARGET);
            try {
                generator.to_file (target);
            } catch (Error e) {
                warning (e.message);
            }
        }

        public virtual void update () {
            
        }

        private void write_build_system (Json.Builder builder) {
            builder.set_member_name (Constants.NATIVE_PROJECT_BUILD_SYSTEM);
            builder.begin_object ();

            builder.set_member_name (Constants.NATIVE_PROJECT_BS_CLEAN_CMD);
            builder.add_string_value (build_system.clean_command);

            builder.set_member_name (Constants.NATIVE_PROJECT_BS_PREBUILD_CMD);
            builder.add_string_value (build_system.prebuild_command);

            builder.set_member_name (Constants.NATIVE_PROJECT_BS_BUILD_CMD);
            builder.add_string_value (build_system.build_command);

            builder.set_member_name (Constants.NATIVE_PROJECT_BS_INTALL_CMD);
            builder.add_string_value (build_system.install_command);

            builder.set_member_name (Constants.NATIVE_PROJECT_BS_RUN_CMD);
            builder.add_string_value (build_system.run_command);

            builder.end_object ();            
        }

        private void write_debug_system (Json.Builder builder) {
            builder.set_member_name (Constants.NATIVE_PROJECT_DEBUG_SYSTEM);
            builder.begin_object ();

            foreach (var template in debug_system.templates) {
                write_template (builder, template);
            }

            builder.end_object ();
        }

        private void write_template (Json.Builder builder, DebugSystem.Template template) {
            builder.set_member_name (template.name);
            builder.begin_object ();

            builder.set_member_name (Constants.NATIVE_PROJECT_DS_TEMPLATE_ENVIRONMENT_VARIABLES);
            builder.begin_object ();

            foreach (var ev in template.environment_variables) {
                builder.set_member_name (ev.name);
                builder.add_string_value (ev.value);
            }

            builder.end_object ();

            var node = new Json.Node (Json.NodeType.ARRAY);

            var array = new Json.Array ();
            foreach (string ra in template.run_arguments) {
                array.add_string_element (ra);
            }

            node.set_array (array);

            builder.set_member_name (Constants.NATIVE_PROJECT_DS_TEMPLATE_RUN_ARGUMENTS);
            builder.add_value (node);

            builder.end_object ();
        }
    }
}