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
    public class TabWidget : Gtk.Box {
        private Gtk.Image unsaved_img;
        private Gtk.Label label_widget;

        private string _label;
        public string label {
            get {
                return _label;
            }

            set {
                _label = value;
                label_widget.label = value;
            }
        }

        private bool _saved;
        public bool saved {
            get {
                return _saved;
            }

            set {
                _saved = value;
                Utils.set_widget_visible (unsaved_img, value);
            }
        }

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;
            
            unsaved_img.halign = Gtk.Align.END;

            label_widget = new Gtk.Label (null);
            label_widget.halign = Gtk.Align.CENTER;

            pack_start (label_widget, true, true, 0);
            pack_end (unsaved_img, false, false, 0);
        }

        public TabWidget (string label = "") {
            label_widget.label = label;
        }
    }
}