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

public class MenuButton : Gtk.MenuButton {
    private Gtk.Menu menu;

    construct {
        menu = new Gtk.Menu ();
        set_popup (menu);
    }

    public MenuButton (string tooltip, string icon_name, Gtk.IconSize size = Gtk.IconSize.LARGE_TOOLBAR) {
        image = new Gtk.Image.from_icon_name (icon_name, size);
        tooltip_text = tooltip;
    }

    public Gtk.MenuItem add_menu_item (string label) {
        var menu_item = new Gtk.MenuItem.with_label (label);
        menu.add (menu_item);
        menu.show_all ();
        return menu_item;
    }
}
