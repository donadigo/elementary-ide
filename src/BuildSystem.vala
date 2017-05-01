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

public class BuildSystem : Object {
    public string prebuild_command { get; set; default = ""; }
    public string build_command { get; set; default = ""; }
    public string install_command { get; set; default = ""; }
    public string run_command { get; set; default = ""; }

    public void build (string build_path, Terminal terminal, bool run_target) throws Error {
        string shell = Utils.get_default_shell ();

        try {
            Pid child_pid;
            terminal.spawn_sync (Vte.PtyFlags.DEFAULT, build_path, { shell, "-c", build_command, null },
                                Environ.get (), SpawnFlags.SEARCH_PATH, null, out child_pid, null);
            ChildWatch.add (child_pid, (pid, status) => {
                Process.close_pid (pid);

                if (status != 0) {
                    terminal.print (_("\nBuild failed: child process exited with status %i\n").printf (status));
                }

                if (run_target) {
                    run (build_path, terminal);
                }
            });            
        } catch (Error e) {
            terminal.print (_("\nInternal error: %s\n").printf (e.message));
        }
    }

    public void rebuild (string root_path, Terminal terminal, bool run_target) throws Error {
        string shell = Utils.get_default_shell ();

        string build_path = Path.build_path (Path.DIR_SEPARATOR_S, root_path, Constants.DEFAULT_BUILD_FOLDER_NAME);
        var build_file = File.new_for_path (build_path);
        if (build_file.query_exists ()) {
            try {
                Utils.remove_directory (build_file);
            } catch (Error e) {
                terminal.print (_("\nBuild failed: failed to remove build directory: %s\n").printf (e.message));
                return;
            }
        }

        build_file.make_directory ();

        try {
            Pid child_pid;
            terminal.spawn_sync (Vte.PtyFlags.DEFAULT, build_path, { shell, "-c", prebuild_command, null },
                                Environ.get (), SpawnFlags.SEARCH_PATH, null, out child_pid, null);

            ChildWatch.add (child_pid, (pid, status) => {
                Process.close_pid (pid);

                if (status != 0) {
                    string message = _("\nPrebuild failed: child process exited with status %i\n").printf (status);
                    terminal.print (message);
                    return;
                }

                try {
                    build (build_path, terminal, run_target);
                } catch (Error e) {
                    terminal.print (_("\nInternal error: %s\n").printf (e.message));
                }
            });
        } catch (Error e) {
            terminal.print (_("\nInternal error: %s\n").printf (e.message));
        }
    }

    public void run (string build_path, Terminal terminal) {
        string shell = Utils.get_default_shell ();
        try {
            terminal.spawn_sync (Vte.PtyFlags.DEFAULT, build_path, { shell, "-c", run_command, null },
                            Environ.get (), SpawnFlags.SEARCH_PATH, null, null, null);
        } catch (Error e) {
            warning (e.message);
        }
    }
}
