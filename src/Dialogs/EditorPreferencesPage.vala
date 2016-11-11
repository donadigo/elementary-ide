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
    public class EditorPreferencesPage : Gtk.ScrolledWindow {
        construct {
            var grid = new Gtk.Grid ();
            grid.margin = 12;

            var list_box = new Gtk.ListBox ();

            var frame = new Gtk.Frame (null);
            frame.add (list_box);

            var font_button = new Gtk.FontButton ();
            font_button.use_font = true;
            font_button.font_name = IDESettings.get_default ().font_desc;
            font_button.font_set.connect (() => {
                IDESettings.get_default ().font_desc = font_button.get_font_desc ().to_string ();
            });

            var appearence_label = new Gtk.Label (_("General"));
            appearence_label.margin_top = appearence_label.margin_bottom = 12;
            appearence_label.halign = Gtk.Align.START;
            appearence_label.get_style_context ().add_class ("h4");

            grid.attach (appearence_label, 0, 0, 1, 1);
            grid.attach (frame, 0, 1, 1, 1);

            var font_box = new EmptyBox (_("Font"), false);
            font_box.grid.add (font_button);
            list_box.add (font_box);

            var sln_box = new EmptyBox (_("Show line numbers"), true);
            sln_box.grid.add (new SettingsSwitch ("show-line-numbers"));
            list_box.add (sln_box);

            var hcl_box = new EmptyBox (_("Higlight current line"), true);
            hcl_box.grid.add (new SettingsSwitch ("highlight-current-line"));
            list_box.add (hcl_box);

            var hs_box = new EmptyBox (_("Highlight syntax"), true);
            hs_box.grid.add (new SettingsSwitch ("highlight-syntax"));
            list_box.add (hs_box);

            var hmb_box = new EmptyBox (_("Highlight matching brackets"), true);
            hmb_box.grid.add (new SettingsSwitch ("highlight-matching-brackets"));
            list_box.add (hmb_box);

            var tts_box = new EmptyBox (_("Convert tabs to spaces"), true);
            tts_box.grid.add (new SettingsSwitch ("tabs-to-spaces"));
            list_box.add (tts_box);

            add (grid);
        }
    }
}