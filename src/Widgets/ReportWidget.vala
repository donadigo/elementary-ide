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

public class ReportWidget : Gtk.ScrolledWindow, BottomWidget {
    public signal void jump_to (string filename, int line, int column);

    private class ReportRow : Gtk.ListBoxRow {
        public ReportMessage report_message;
        private Gtk.Image image;
        private Gtk.Label label;

        construct {
            image = new Gtk.Image ();
            label = new Gtk.Label (null);

            var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            main_box.margin = 6;
            main_box.add (image);
            main_box.add (label);
            add (main_box);
        }

        public ReportRow (ReportMessage report_message) {
            this.report_message = report_message;

            image.set_from_icon_name (report_message.to_icon_name (), Gtk.IconSize.SMALL_TOOLBAR);
            label.label = "%s (%s)".printf (report_message.message, report_message.source.to_string ());
        }
    }

    public Gtk.Widget? toolbar_widget {
        get {
            return type_combo;
        }
    }

    private Gtk.ListBox list_box;
    private Gtk.ComboBoxText type_combo;

    construct {
        min_content_height = 30;

        list_box = new Gtk.ListBox ();
        list_box.selection_mode = Gtk.SelectionMode.SINGLE;
        list_box.activate_on_single_click = true;
        list_box.expand = true;

        list_box.set_filter_func (filter_func);
        list_box.set_sort_func (sort_func);
        list_box.row_activated.connect (on_row_activated);

        int all = -1;
        string all_str = all.to_string ();

        type_combo = new Gtk.ComboBoxText ();
        type_combo.append (all_str, _("All"));
        type_combo.append (((int)ReportType.NOTE).to_string (), _("Notes"));
        type_combo.append (((int)ReportType.WARNING).to_string (), _("Warnings"));
        type_combo.append (((int)ReportType.ERROR).to_string (), _("Errors"));
        type_combo.active_id = all_str;
        type_combo.changed.connect (() => list_box.invalidate_filter ());

        add (list_box);
    }

    public void set_report (Report report) {
        foreach (var message in report.get_messages ()) {
            add_message (message);
        }
    }

    public void add_message (ReportMessage report_message) {
        var row = new ReportRow (report_message);
        list_box.add (row);
        show_all ();
    }

    public void clear () {
        foreach (var child in list_box.get_children ()) {
            child.destroy ();
        }
    }

    private bool filter_func (Gtk.ListBoxRow row) {
        var report_row = row as ReportRow;
        if (report_row == null) {
            return true;
        }

        string? id = type_combo.get_active_id ();
        if (id == null) {
            return true;
        }

        int type = int.parse (id);
        if (type == -1) {
            return true;
        }

        return type == ((ReportRow)row).report_message.report_type;
    }

    private int sort_func (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        if (!(row1 is ReportRow) || !(row2 is ReportRow)) {
            return 0;
        }

        int type1 = ((ReportRow)row1).report_message.report_type;
        int type2 = ((ReportRow)row2).report_message.report_type;

        if (type1 > type2) {
            return 1;
        } else if (type1 < type2) {
            return -1;
        }

        return 0;
    }

    private void on_row_activated (Gtk.ListBoxRow row) {
        var report_row = row as ReportRow;
        if (report_row == null) {
            return;
        }

        var message = report_row.report_message;
        if (message.source == null || message.source.file == null) {
            return;
        }

        jump_to (message.source.file.filename, message.source.begin.line - 1, message.source.begin.column - 1);
    }
}
