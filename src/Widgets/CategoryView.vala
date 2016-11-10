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
    public class CategoryView : Gtk.Paned {
        private class CategoryRow : Gtk.ListBoxRow {
            private Gtk.Image image;
            private Gtk.Label label;

            construct {
                image = new Gtk.Image ();
                image.icon_size = Gtk.IconSize.DND;

                label = new Gtk.Label (null);

                var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
                box.margin_start = 12;
                box.margin_top = margin_bottom = 6;
                box.add (image);
                box.add (label);

                add (box);
            }

            public CategoryRow (string icon_name, string title) {
                image.icon_name = icon_name;
                label.label = title;
            }
        }

        public Gtk.Stack stack { get; construct; }
        private Gtk.ListBox list_box;

        construct {
            expand = true;

            var scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;

            list_box = new Gtk.ListBox ();
            scrolled.add (list_box);

            add1 (scrolled);

            stack = new Gtk.Stack ();
            add2 (stack);
        }

        public int add_pane (string icon_name, string title) {
            var row = new CategoryRow (icon_name, title);
            list_box.add (row);
            show_all ();
            return row.get_index ();
        }
    }
}