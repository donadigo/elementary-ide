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

public class NativeProject : Project {
    private string target;

    public new static async Project? load (File file) {
        string target = Path.build_filename (file.get_path (), Constants.NATIVE_TARGET);
        if (!FileUtils.test (target, FileTest.IS_REGULAR)) {
            return null;
        }

        var project = new NativeProject (target);
        return project;
    }

    public NativeProject (string target) {
        this.target = target;
        root_path = Path.get_dirname (target);

        update ();
    }

    public override void update () {
        try {
            var parser = new Json.Parser ();
            parser.load_from_file (target);

            var root = parser.get_root ();
            var obj = root.get_object ();
            foreach (unowned string member in obj.get_members ()) {
                switch (member) {
                    case Constants.NATIVE_PROJECT_NAME:
                        name = obj.get_string_member (member);
                        break;
                    case Constants.NATIVE_PROJECT_PROJECT_DIRECTORY:
                        root_path = obj.get_string_member (member);
                        break;
                    case Constants.NATIVE_PROJECT_PROJECT_TYPE:
                        project_type = (ProjectType)obj.get_int_member (member);
                        break;
                    case Constants.NATIVE_PROJECT_VERSION:
                        version = obj.get_string_member (member);
                        break;
                    case Constants.NATIVE_PROJECT_EXECUTABLE_PATH:
                        executable_path = obj.get_string_member (member);
                        break;
                    case Constants.NATIVE_PROJECT_PACKAGES:
                        var array = obj.get_array_member (member);
                        foreach (unowned Json.Node node in array.get_elements ()) {
                            packages.add (node.get_string ());
                        }

                        break;
                    case Constants.NATIVE_PROJECT_SOURCES:
                        var array = obj.get_array_member (member);
                        foreach (unowned Json.Node node in array.get_elements ()) {
                            sources.add (node.get_string ());
                        }

                        break;
                    case Constants.NATIVE_PROEJCT_DEPENDENCIES:
                        var array = obj.get_array_member (member);
                        foreach (unowned Json.Node node in array.get_elements ()) {
                            dependencies.add (node.get_string ());
                        }

                        break;
                    case Constants.NATIVE_PROJECT_VALA_OPTIONS:
                        var array = obj.get_array_member (member);
                        foreach (unowned Json.Node node in array.get_elements ()) {
                            vala_options.add (node.get_string ());
                        }

                        break;
                    case Constants.NATIVE_PROJECT_BUILD_SYSTEM:
                        var build_obj = obj.get_object_member (member);
                        read_build_system_object (build_obj);
                        break;
                    case Constants.NATIVE_PROJECT_DEBUG_SYSTEM:
                        var debug_obj = obj.get_object_member (member);
                        read_debug_system_object (debug_obj);

                        break;
                }
            }
        } catch (Error e) {
            warning (e.message);
        }
    }


    private void read_build_system_object (Json.Object build_obj) {
        build_system.prebuild_command = build_obj.get_string_member (Constants.NATIVE_PROJECT_BS_PREBUILD_CMD);
        build_system.build_command = build_obj.get_string_member (Constants.NATIVE_PROJECT_BS_BUILD_CMD);
        build_system.install_command = build_obj.get_string_member (Constants.NATIVE_PROJECT_BS_INTALL_CMD);
        build_system.run_command = build_obj.get_string_member (Constants.NATIVE_PROJECT_BS_RUN_CMD);            
    }

    private void read_debug_system_object (Json.Object debug_obj) {
        foreach (unowned string template_name in debug_obj.get_members ()) {
            var template = new DebugSystem.Template (template_name);
            var template_obj = debug_obj.get_object_member (template_name);

            var ev_obj = template_obj.get_object_member (Constants.NATIVE_PROJECT_DS_TEMPLATE_ENVIRONMENT_VARIABLES);
            foreach (unowned string ev_member in ev_obj.get_members ()) {
                var ev = new DebugSystem.EnvironmentVariable (ev_member, ev_obj.get_string_member (ev_member));
                template.environment_variables.add (ev);
            }

            var array = template_obj.get_array_member (Constants.NATIVE_PROJECT_DS_TEMPLATE_RUN_ARGUMENTS);
            foreach (unowned Json.Node node in array.get_elements ()) {
                template.run_arguments.add (node.get_string ());
            }

            debug_system.templates.add (template);
        }
    }
}
