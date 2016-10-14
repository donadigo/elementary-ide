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
    public class Sidebar : Gtk.TreeView {
        private File file;
        private Gtk.TreeStore store;

        construct {
            store = new Gtk.TreeStore (3, typeof (string), typeof (string), typeof (string));
            model = store;

            headers_visible = false;
            activate_on_single_click = true;

            // TODO: margins and spacing
            var column = new Gtk.TreeViewColumn ();

            var pixbuf = new Gtk.CellRendererPixbuf ();
            column.pack_start (pixbuf, false);
            column.add_attribute (pixbuf, "icon-name", 1);
            append_column (column);

            var cell = new Gtk.CellRendererText ();
            insert_column_with_attributes (-1, null, cell, "text", 2);

            get_style_context ().add_class ("sidebar");
        }

        public void get_iter (out Gtk.TreeIter iter, Gtk.TreePath path) {
            model.get_iter (out iter, path);
        }

        public void set_file (File file) {
            this.file = file;
            update_file ();
        }

        private void update_file () {
            store.clear ();
            process_directory (file, null);
        }

        private void process_directory (File directory, Gtk.TreeIter? prev_iter) {
            try {
                var enumerator = directory.enumerate_children ("standard::*", FileQueryInfoFlags.NONE, null);

                FileInfo? info;
                while ((info = enumerator.next_file ()) != null) {
                    if (info.get_name ().has_prefix (".")) {
                        continue;
                    }

                    var subfile = directory.resolve_relative_path (info.get_name ());
                    if (info.get_file_type () == FileType.DIRECTORY) {
                        Gtk.TreeIter iter;
                        store.append (out iter, prev_iter);
                        store.set (iter, 0, subfile.get_path (), 1, "folder", 2, info.get_name ());

                        process_directory (subfile, iter);
                    } else {
                        string icon_name;
                        var icon = (ThemedIcon)info.get_icon ();

                        string[] names = icon.get_names ();
                        if (names.length > 0 && Gtk.IconTheme.get_default ().has_icon (names[0])) {
                            icon_name = icon.get_names ()[0];
                        } else {
                            icon_name = "application-octet-stream";
                        }

                        Gtk.TreeIter iter;
                        store.append (out iter, prev_iter);
                        store.set (iter, 0, subfile.get_path (), 1, icon_name, 2, info.get_name ());
                    }
                }
            } catch (Error e) {
                warning (e.message);
            }
        }
    }
}