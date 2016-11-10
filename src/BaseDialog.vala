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
    public class BaseDialog : Gtk.Dialog {
        construct {
            deletable = false;
            margin = 24;

            set_transient_for (IDEApplication.get_main_window ());
            var action_area = (Gtk.Box)get_action_area ();

            var close_button = new Gtk.Button.with_label (_("Close"));
            close_button.clicked.connect (() => hide ());
            action_area.pack_end (close_button, false, false, 0);
        }

        public override bool delete_event (Gdk.EventAny event) {
            hide ();
            return true;
        }        
    }
}