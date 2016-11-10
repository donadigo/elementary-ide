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
    public class SettingsLabel : Gtk.Label {
        construct {
            halign = Gtk.Align.END;
        }

        public SettingsLabel (string title) {
            label = title;
        }
    }

    public class SettingsSwitch : Gtk.Switch {
        construct {
            halign = Gtk.Align.START;
        }

        public SettingsSwitch (string key) {
            IDESettings.get_default ().schema.bind (key, this, "active", SettingsBindFlags.DEFAULT);
        }
    }

    private class SettingsRow : Gtk.ListBoxRow {
        public string id { get; construct; }

        private Gtk.Image image;
        private Gtk.Label label;

        construct {
            image = new Gtk.Image ();
            image.icon_size = Gtk.IconSize.DND;

            label = new Gtk.Label (null);

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            box.margin_start = 12;
            box.margin_top = box.margin_bottom = 6;

            box.add (image);
            box.add (label);

            add (box);
        }

        public SettingsRow (string title, string icon_name, string id) {
            Object (id: id);
            label.label = title;
            image.icon_name = icon_name;
        }
    }

    public class EmptyBox : Gtk.ListBoxRow {
        public Gtk.Grid grid { get; construct; }
        private Gtk.Label label;

        construct {
            activatable = false;
            selectable = false;

            label = new Gtk.Label (null);
            label.hexpand = true;
            label.halign = Gtk.Align.START;
            label.margin = 6;

            grid = new Gtk.Grid ();
            grid.hexpand = true;
            grid.halign = Gtk.Align.END;
            grid.set_margin_end (12);
            grid.set_margin_top (8);
            grid.set_margin_bottom (8);            
        }

        public EmptyBox (string title, bool add_separator) {
            set_activatable (false);
            set_selectable (false);

            label.label = title;

            var main_grid = new Gtk.Grid ();

            if (add_separator) {
                main_grid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 0, 2, 1);
            }

            main_grid.attach (label, 0, 1, 1, 1);
            main_grid.attach (grid, 1, 1, 1, 1);
            add (main_grid);

            show_all ();
        }
    }

    public class EditorPreferencesDialog : BaseDialog {
        private Gtk.Stack main_stack;

        construct {
            set_default_size (800, 600);
            main_stack = new Gtk.Stack ();

            var list_box = new Gtk.ListBox ();

            var stack = new Gtk.Stack ();

            var scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled.width_request = 176;
            scrolled.add (list_box);

            var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            paned.expand = true;
            paned.pack1 (scrolled, false, false);
            paned.add2 (stack);

            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            box.expand = true;
            box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            box.add (paned);
            box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

            var editor_row = new SettingsRow (_("Editor"), "document-page-setup", "editor");
            list_box.add (editor_row);

            var ep_page = new EditorPreferencesPage ();
            stack.add_named (ep_page, "editor");
            stack.visible_child_name = "editor";
            stack.show_all ();

            get_content_area ().add (box);
        }
    }
}