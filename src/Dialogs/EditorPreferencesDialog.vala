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
    public class EditorPreferencesDialog : BaseDialog {
        private EditorWindow editor_window;

        private Gtk.Stack main_stack;

        construct {
            main_stack = new Gtk.Stack ();
            main_stack.add_titled (new Gtk.Grid (), "syntax", _("Syntax"));

            var stack_switcher = new Gtk.StackSwitcher ();
            stack_switcher.set_stack (main_stack);
            stack_switcher.halign = Gtk.Align.CENTER;

            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
            main_box.pack_start (stack_switcher, false, false);
            main_box.pack_start (main_stack, true, true);
            get_content_area ().add (main_box);
        }

        public EditorPreferencesDialog (EditorWindow editor_window) {
            this.editor_window = editor_window;
            show_all ();
        }
    }
}