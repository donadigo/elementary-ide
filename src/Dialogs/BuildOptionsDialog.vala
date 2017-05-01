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

public class BuildOptionsDialog : BaseDialog {
    public Gtk.Entry prebuild_entry { get; construct; }
    public Gtk.Entry build_entry { get; construct; }
    public Gtk.Entry run_entry { get; construct; }

    construct {
        set_default_size (800, 600);

        var grid = new Gtk.Grid ();
        grid.row_spacing = 12;
        grid.margin = 12;

        var frame = new SettingsFrame ();

        var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.BOTH);

        prebuild_entry = new Gtk.Entry ();
        prebuild_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        prebuild_entry.get_style_context ().add_class ("h4");
        prebuild_entry.width_request = 450;
        size_group.add_widget (prebuild_entry);

        build_entry = new Gtk.Entry ();
        build_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        build_entry.get_style_context ().add_class ("h4");
        size_group.add_widget (build_entry);

        run_entry = new Gtk.Entry ();
        run_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        run_entry.get_style_context ().add_class ("h4");
        size_group.add_widget (run_entry);

        var prebuild_box = new SettingBox (_("Prebuild command"), false);
        prebuild_box.grid.add (prebuild_entry);
        frame.add_widget (prebuild_box);

        var build_box = new SettingBox (_("Build command"), true);
        build_box.grid.add (build_entry);
        frame.add_widget (build_box);

        var run_box = new SettingBox (_("Run command"), true);
        run_box.grid.add (run_entry);
        frame.add_widget (run_box);

        grid.attach (frame, 0, 0, 1, 1);
        get_content_area ().add (grid);
    }
}