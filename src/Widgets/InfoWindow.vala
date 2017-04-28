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

// TODO: make use of native tooltips, remove this
public class InfoWindow : Gtk.Window {
    private Gtk.Label tooltip_label;

    construct {
        type = Gtk.WindowType.POPUP;
        type_hint = Gdk.WindowTypeHint.TOOLTIP;
        name = "gtk-tooltip";
        skip_taskbar_hint = true;
        decorated = false;
        focus_on_map = true;
        resizable = false;

        get_style_context ().add_class (Gtk.STYLE_CLASS_TOOLTIP);
        set_accessible_role (Atk.Role.TOOL_TIP);

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        tooltip_label = new Gtk.Label (null);
        tooltip_label.max_width_chars = 120;
        tooltip_label.wrap = true;
        tooltip_label.margin = 6;
        box.add (tooltip_label);
        add (box);
    }

    public void set_label (string label) {
        tooltip_label.label = label;
    }

    public void show_at (int x, int y) {
        move (x, y);
        show_all ();
    }
}