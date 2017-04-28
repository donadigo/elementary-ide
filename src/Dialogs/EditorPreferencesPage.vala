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

public class EditorPreferencesPage : Gtk.ScrolledWindow {
    construct {
        var grid = new Gtk.Grid ();
        grid.row_spacing = 12;
        grid.margin = 12;

        var general_frame = new SettingsFrame ();
        var highlight_frame = new SettingsFrame ();
        var behaviour_frame = new SettingsFrame ();

        var font_button = new Gtk.FontButton ();
        font_button.use_font = true;
        font_button.font_name = IDESettings.get_default ().font_desc;
        font_button.font_set.connect (() => {
            IDESettings.get_default ().font_desc = font_button.get_font_desc ().to_string ();
        });

        var general_label = new HeaderLabel (_("General"));
        var highlight_label = new HeaderLabel (_("Highlighting"));
        var behaviour_label = new HeaderLabel (_("Behaviour"));

        grid.attach (general_label, 0, 0, 1, 1);
        grid.attach (general_frame, 0, 1, 1, 1);

        grid.attach (highlight_label, 0, 2, 1, 1);
        grid.attach (highlight_frame, 0, 3, 1, 1);

        grid.attach (behaviour_label, 0, 4, 1, 1);
        grid.attach (behaviour_frame, 0, 5, 1, 1);

        var font_box = new SettingBox (_("Font"), false);
        font_box.grid.add (font_button);
        general_frame.add_widget (font_box);

        var sln_box = new SettingBox (_("Show line numbers"), true);
        sln_box.grid.add (new SettingSwitch ("show-line-numbers"));
        general_frame.add_widget (sln_box);

        var hcl_box = new SettingBox (_("Higlight current line"), false);
        hcl_box.grid.add (new SettingSwitch ("highlight-current-line"));
        highlight_frame.add_widget (hcl_box);

        var hs_box = new SettingBox (_("Highlight syntax"), true);
        hs_box.grid.add (new SettingSwitch ("highlight-syntax"));
        highlight_frame.add_widget (hs_box);

        var hmb_box = new SettingBox (_("Highlight matching brackets"), true);
        hmb_box.grid.add (new SettingSwitch ("highlight-matching-brackets"));
        highlight_frame.add_widget (hmb_box);

        var tts_box = new SettingBox (_("Convert tabs to spaces"), false);
        tts_box.grid.add (new SettingSwitch ("tabs-to-spaces"));
        behaviour_frame.add_widget (tts_box);

        var dst_box = new SettingBox (_("Draw spaces and tabs"), false);
        dst_box.grid.add (new SettingSwitch ("draw-spaces-tabs"));
        behaviour_frame.add_widget (dst_box);

        add (grid);
    }
}
