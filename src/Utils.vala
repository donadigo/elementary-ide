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

namespace Utils {
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

    public static void remove_directory (File file) throws Error {
        var enumerator = file.enumerate_children ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);

        FileInfo? info = null;
        while ((info = enumerator.next_file (null)) != null) {
            if (info.get_file_type () == FileType.DIRECTORY) {
                var subdir = file.resolve_relative_path (info.get_name ());
                remove_directory (subdir);
            } else {
                var subfile = file.resolve_relative_path (info.get_name ());
                try {
                    subfile.@delete ();
                } catch (Error e) {
                    throw e;
                }
            }
        }

        try {
            file.@delete ();
        } catch (Error e) {
            throw e;
        }
    }

    public static string get_default_shell () {
        return Environment.get_variable ("SHELL");
    }

    public static string get_extension (File file) {
        string basename = file.get_basename ();
        int idx = basename.last_index_of (".");
        if (idx == -1) {
            return basename;
        }

        return basename.substring (idx + 1);
    }

    public static string get_filename_display (string filename) {
        int idx = filename.last_index_of (".");
        if (idx == -1) {
            return filename;
        }

        return filename.substring (0, idx);        
    }

    public static string esc_angle_brackets (string in) {
        return in.replace ("<", "&lt;").replace (">", "&gt;");
    }    
}