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

namespace IDE.Utils {
    public static void set_widget_visible (Gtk.Widget widget, bool visible) {
        widget.no_show_all = !visible;
        if (visible) {
            widget.show_all ();
        } else {
            widget.hide ();
        }
    }

    public static bool get_file_exists (string filename) {
        return FileUtils.test (filename, FileTest.IS_REGULAR);
    }

    public static Gtk.ResponseType show_warning_dialog (string title, string message, string icon = "warning") {
        return Gtk.ResponseType.ACCEPT;
    }

    public static void show_error_dialog (string title, string message, string icon = "error-dialog") {

    }

    public static string get_basename_relative_path (string root_filename, string filename) {
        string path = Path.get_dirname (filename).substring (root_filename.length);
        string skipped = Path.skip_root (path);
        return skipped;
    }

    public static string get_extension (File file) {
        string basename = file.get_basename ();
        int idx = basename.last_index_of (".");

        return basename.substring (idx + 1);
    }

    public static string esc_angle_brackets (string in) {
        return in.replace ("<", "&lt;").replace (">", "&gt;");
    }    
}