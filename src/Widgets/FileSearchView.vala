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
    public class FileSearchView : Gtk.ScrolledWindow {
        private class FileResultRow : Gtk.ListBoxRow {
            public FileSearchResult result { public get; construct; }
            private Gtk.Label subtitle_label;

            construct {
                var image = new Gtk.Image.from_gicon (result.icon, Gtk.IconSize.DND);
                var filename_label = new Gtk.Label ("<b>" + Path.get_basename (result.filename) + "</b>");
                filename_label.ellipsize = Pango.EllipsizeMode.MIDDLE;
                filename_label.max_width_chars = 30;
                filename_label.use_markup = true;
                filename_label.halign = Gtk.Align.START;

                subtitle_label = new Gtk.Label (null);
                subtitle_label.ellipsize = Pango.EllipsizeMode.MIDDLE;
                subtitle_label.max_width_chars = 20;
                subtitle_label.halign = Gtk.Align.START;

                var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
                box.add (filename_label);
                box.add (subtitle_label);

                var main_grid = new Gtk.Grid ();
                main_grid.hexpand = true;
                main_grid.margin = 6;
                main_grid.column_spacing = 6;
                main_grid.attach (image, 0, 0, 1, 1);
                main_grid.attach (box, 1, 0, 1, 1);

                add (main_grid);
            }

            public FileResultRow (FileSearchResult result, string root_filename) {
                Object (result: result);
                subtitle_label.label = Utils.get_basename_relative_path (root_filename, result.filename);
            }
        }

        public signal void result_activated (FileSearchResult result);

        private Gtk.Stack stack_placeholder;
        private Gtk.Label no_search_results_label;
        private Gtk.Spinner spinner;
        private Gtk.ListBox list_box;

        private FileSearchEngine search_engine;

        construct {
            hscrollbar_policy = Gtk.PolicyType.NEVER;

            spinner = new Gtk.Spinner ();
            spinner.start ();

            var grid = new Gtk.Grid ();
            grid.halign = grid.valign = Gtk.Align.CENTER;
            grid.add (spinner);

            no_search_results_label = new Gtk.Label (null);
            no_search_results_label.justify = Gtk.Justification.CENTER;
            no_search_results_label.get_style_context ().add_class ("h3");
            no_search_results_label.wrap_mode = Pango.WrapMode.WORD_CHAR;
            no_search_results_label.wrap = true;
            no_search_results_label.max_width_chars = 30;

            stack_placeholder = new Gtk.Stack ();
            stack_placeholder.add_named (grid, Constants.FILE_SEARCH_VIEW_SPINNER_NAME);
            stack_placeholder.add_named (no_search_results_label, Constants.FILE_SEARCH_NO_RESULTS_VIEW_NAME);
            stack_placeholder.show_all ();

            list_box = new Gtk.ListBox ();
            list_box.set_placeholder (stack_placeholder);
            list_box.row_activated.connect (on_row_activated);
            list_box.activate_on_single_click = true;
            list_box.selection_mode = Gtk.SelectionMode.SINGLE;
            add (list_box);

            search_engine = new FileSearchEngine ();
        }

        public void set_search_directory (string? filename) {
            search_engine.root_filename = filename;
        }

        public async void search (string query, bool include_hidden) {
            if (search_engine.root_filename == null) {
                return;
            }

            spinner.start ();
            stack_placeholder.visible_child_name = Constants.FILE_SEARCH_VIEW_SPINNER_NAME;
            clear ();

            var results = yield search_engine.search_files (query, include_hidden);
            foreach (var result in results) {
                var row = new FileResultRow (result, search_engine.root_filename);
                list_box.add (row);
            }

            no_search_results_label.label = _("No search results for \"%s\"").printf (query);
            stack_placeholder.visible_child_name = Constants.FILE_SEARCH_NO_RESULTS_VIEW_NAME;
            spinner.stop ();
            show_all ();
        }

        private void clear () {
            foreach (var child in list_box.get_children ()) {
                child.destroy ();
            }
        }

        private void on_row_activated (Gtk.ListBoxRow row) {
            var result_row = (FileResultRow)row;
            if (result_row == null) {
                return;
            }

            result_activated (result_row.result);
        }
    }
}