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

public class BuildOutputWidget : TerminalWidget, BottomWidget {
    public new Gtk.Widget? toolbar_widget {
        get {
            return null;
        }
    }

    public void build (Project project, bool run) {
        clear ();

        string build_path = Path.build_path (Path.DIR_SEPARATOR_S, project.root_path, Constants.DEFAULT_BUILD_FOLDER_NAME);

        try {
            var build_file = File.new_for_path (build_path);
            if (!build_file.query_exists ()) {
                project.build_system.rebuild (project.root_path, terminal, run);
            } else {
                project.build_system.build (build_path, terminal, run);
            }
        } catch (Error e) {
            warning (e.message);
        }
    }

    public void rebuild (Project project) {
        clear ();

        try {
            project.build_system.rebuild (project.root_path, terminal, false);
        } catch (Error e) {
            warning (e.message);
        }            
    }
}