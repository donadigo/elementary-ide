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
    public class HeaderLabel : Gtk.Label {
        construct {
            halign = Gtk.Align.START;
            get_style_context ().add_class ("h4");            
        }

        public HeaderLabel (string title) {
            label = title;
        }
    }

    public class SettingSwitch : Gtk.Switch {
        construct {
            halign = Gtk.Align.START;
        }

        public SettingSwitch (string key) {
            IDESettings.get_default ().schema.bind (key, this, "active", SettingsBindFlags.DEFAULT);
        }
    }

    public class SettingBox : Gtk.ListBoxRow {
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

        public SettingBox (string title, bool add_separator) {
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

	public class SettingsFrame : Gtk.Frame {
		private Gtk.ListBox list_box;

		construct {
			list_box = new Gtk.ListBox ();
			add (list_box);
		}

		public void add_widget (Gtk.Widget widget) {
			list_box.add (widget);
		}
	}
}