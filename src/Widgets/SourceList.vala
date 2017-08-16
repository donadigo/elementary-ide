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

public class SourceList : Granite.Widgets.SourceList {
    public class Item : Granite.Widgets.SourceList.ExpandableItem, Granite.Widgets.SourceListSortable {
        public string filename { get; construct set; }
        public int compare (Granite.Widgets.SourceList.Item a, Granite.Widgets.SourceList.Item b) {
            if (a is FolderItem && b is FileItem) {
                return -1;
            } else if (a is FileItem && b is FolderItem) {
                return 1;
            }
            return strcmp ((a as Item).filename, (b as Item).filename);
        }
        public bool allow_dnd_sorting () {
            return false;
        }
    }

    public class FileItem : Item {
        public FileItem (string filename, string name, string icon_name) {
            this.filename = filename;
            this.name = name;
            icon = new ThemedIcon (icon_name);
        }
    }

    public class FolderItem : Item {
        public FolderItem (string filename, string name) {
            this.filename = filename;
            this.name = name;
            icon = new ThemedIcon ("folder");
        }
    }

    private File file;
    private FolderItem project_root;

    public SourceList () {
        ellipsize_mode = Pango.EllipsizeMode.MIDDLE;
    }

    public void set_file (File file) {
        root.clear ();

        this.file = file;
        project_root = new FolderItem (file.get_path (), file.get_basename ());
        project_root.expand_all (true, false);
        root.add (project_root);
        update_file ();
    }

    private void update_file () {
        process_directory.begin (file, null);
    }

    private async void process_directory (File directory, Granite.Widgets.SourceList.ExpandableItem? prev_item) {
        try {
            var enumerator = yield directory.enumerate_children_async ("standard::*", FileQueryInfoFlags.NONE);

            FileInfo? info;
            while ((info = enumerator.next_file ()) != null) {
                if (info.get_name ().has_prefix (".")) {
                    continue;
                }

                var subfile = directory.resolve_relative_path (info.get_name ());
                if (info.get_file_type () == FileType.DIRECTORY) {
                    var expandable_item = new FolderItem (subfile.get_path (), info.get_name ());
                    if (prev_item != null) {
                        prev_item.add (expandable_item);
                    } else {
                        project_root.add (expandable_item);
                    }

                    process_directory.begin (subfile, expandable_item);
                } else {
                    string icon_name;
                    var icon = (ThemedIcon)info.get_icon ();

                    string[] names = icon.get_names ();
                    if (names.length > 0 && Gtk.IconTheme.get_default ().has_icon (names[0])) {
                        icon_name = icon.get_names ()[0];
                    } else {
                        icon_name = "application-octet-stream";
                    }

                    var item = new FileItem (subfile.get_path (), info.get_name (), icon_name);
                    if (prev_item != null) {
                        prev_item.add (item);
                    } else {
                        project_root.add (item);
                    }
                }
            }
        } catch (Error e) {
            warning (e.message);
        }
    }
}
