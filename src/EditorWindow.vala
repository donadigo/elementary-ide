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
    public class EditorWindow : Gtk.Box {
        public signal void show_info_window (Gtk.TextIter start_iter, int x, int y);
        public signal void close_info_window ();

        public Gtk.SourceView source_view { get; private set; }
        public Gtk.SourceBuffer source_buffer { get; private set; }
        private Gtk.SourceMap source_map;
        private Gtk.ProgressBar progress_bar;
        private Gtk.ScrolledWindow view_scrolled;

        private uint show_info_timeout_id = 0;

        public int current_line { 
            get {
                Gtk.TextIter iter;
                source_buffer.get_iter_at_mark (out iter, source_buffer.get_insert ());
                return iter.get_line ();
            }
        }
        public int current_column { 
            get {
                Gtk.TextIter iter;
                source_buffer.get_iter_at_mark (out iter, source_buffer.get_insert ());
                return iter.get_line_offset ();
            }
        }

        construct {
            orientation = Gtk.Orientation.VERTICAL;

            source_buffer = new Gtk.SourceBuffer (null);

            // TODO: better colors here
            var red = Gdk.RGBA ();
            red.red = 1;
            red.green = 0.1;
            red.alpha = 0.5;

            var yellow = Gdk.RGBA ();
            yellow.red = 1;
            yellow.green = 1;
            yellow.blue = 0.1;
            yellow.alpha = 0.5;

            var blue = Gdk.RGBA ();
            blue.green = 0.1;
            blue.blue = 1;
            blue.alpha = 0.5;

            source_buffer.create_tag ("error-tag", "background-rgba", red);
            source_buffer.create_tag ("warning-tag", "background-rgba", yellow);
            source_buffer.create_tag ("info-tag", "background-rgba", blue);
            source_buffer.highlight_syntax = true;

            source_view = new Gtk.SourceView.with_buffer (source_buffer);
            source_view.auto_indent = true;
            source_view.highlight_current_line = true;
            source_view.indent_on_tab = true;
            source_view.indent_width = 4;
            source_view.insert_spaces_instead_of_tabs = true;
            source_view.show_line_numbers = true;
            source_view.show_right_margin = false;
            source_view.smart_backspace = true;
            source_view.smart_home_end = Gtk.SourceSmartHomeEndType.BEFORE;
            source_view.tab_width = 4;
            source_view.background_pattern = Gtk.SourceBackgroundPatternType.GRID;
            source_view.completion.select_on_show = true;
            source_view.completion.show_icons = true;
            source_view.completion.remember_info_visibility = true;
            source_view.left_margin = 5;
            source_view.motion_notify_event.connect (on_motion_notify_event);

            expand = true;

            progress_bar = new Gtk.ProgressBar ();
            progress_bar.show_text = false;  
            progress_bar.halign = Gtk.Align.START;
            progress_bar.valign = Gtk.Align.START;
            Utils.set_widget_visible (progress_bar, false);

            view_scrolled = new Gtk.ScrolledWindow (null, null);
            view_scrolled.add (source_view);

            var label = new Gtk.Label (_("Line 18, Column 56"));
            label.opacity = 0.7;
            label.halign = Gtk.Align.END;
            label.valign = Gtk.Align.END;

            var overlay = new Gtk.Overlay ();
            overlay.add (view_scrolled);
            overlay.add_overlay (progress_bar);

            source_map = new Gtk.SourceMap ();
            source_map.set_view (source_view);

            var editor_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            editor_container.pack_start (overlay, true, true, 0);
            editor_container.pack_start (source_map, false, true, 0);

            pack_start (editor_container, true, true, 0);
        }

        public void set_language (Gtk.SourceLanguage lang) {
            source_buffer.set_language (lang);
        }

        public void set_progress (double progress) {
            progress_bar.set_fraction (progress);
            Utils.set_widget_visible (progress_bar, progress > 0.0 && progress < 1.0);
        }

        public void reset_report_tags () {
            Gtk.TextIter start_iter;
            Gtk.TextIter end_iter;
            source_buffer.get_start_iter (out start_iter);
            source_buffer.get_end_iter (out end_iter);

            source_buffer.remove_tag_by_name ("error-tag", start_iter, end_iter);
            source_buffer.remove_tag_by_name ("warning-tag", start_iter, end_iter);
            source_buffer.remove_tag_by_name ("info-tag", start_iter, end_iter);
        }

        public void apply_report_message (ReportMessage message) {
            Gtk.TextIter start_iter;
            Gtk.TextIter end_iter = Gtk.TextIter ();

            source_buffer.get_iter_at_mark (out start_iter, source_buffer.get_insert ());
            end_iter.assign (start_iter);

            start_iter.set_line (message.source.begin.line - 1);
            start_iter.set_line_offset (message.source.begin.column - 1);

            end_iter.set_line (message.source.end.line - 1);
            end_iter.set_line_offset (message.source.end.column);

            switch (message.report_type) {
                case ReportType.WARNING:
                case ReportType.DEPRECATION:
                    source_buffer.apply_tag_by_name ("warning-tag", start_iter, end_iter);
                    break;
                case ReportType.NOTE:
                    source_buffer.apply_tag_by_name ("info-tag", start_iter, end_iter);
                    break;
                case ReportType.ERROR:
                    source_buffer.apply_tag_by_name ("error-tag", start_iter, end_iter);
                    break;
            }
        }

        public void set_buffer (Gtk.TextBuffer buffer) {
            source_view.set_buffer (buffer);
        }

        public Gtk.SourceBuffer get_buffer () {
            return (Gtk.SourceBuffer)source_view.get_buffer ();
        }

        private void settings_button_clicked (Gtk.Button sender) {
            sender.sensitive = false;

            var dialog = new EditorPreferencesDialog (this);
            dialog.hide.connect (() => sender.sensitive = true);
        }

        /*private void add_providers () {
            var word_provider = new Gtk.SourceCompletionWords (_("Word Completion"), null);
            word_provider.activation = Gtk.SourceCompletionActivation.INTERACTIVE;
            word_provider.interactive_delay = 100;
            word_provider.minimum_word_size = 3;
            word_provider.register (source_buffer);
            source_view.completion.add_provider (word_provider);
        }*/

        private bool on_motion_notify_event (Gdk.EventMotion event) {
            if (show_info_timeout_id > 0) {
                Source.remove (show_info_timeout_id);
                close_info_window ();
            }

            show_info_timeout_id = Timeout.add (1000, () => {
                return show_info_func (event);
            });

            return base.motion_notify_event (event);
        }

        private bool show_info_func (Gdk.EventMotion event) {
            show_info_timeout_id = 0;

            Gdk.Rectangle rect;
            source_view.get_visible_rect (out rect);

            int x = (int)event.x + rect.x;
            int y = (int)event.y + rect.y;

            Gtk.TextIter start_iter;
            source_view.get_iter_at_location (out start_iter, x, y);

            Gtk.TextIter end_iter = Gtk.TextIter ();
            end_iter.assign (start_iter);
            end_iter.forward_to_line_end ();

            if (end_iter.get_line () > start_iter.get_line ()
                || source_buffer.get_text (start_iter, end_iter, false).strip () == ""
                || end_iter.get_line_offset () <= start_iter.get_line_offset ()) {
                return false;
            }

            show_info_window (start_iter, (int)event.x_root + 10, (int)event.y_root);

            return false;
        }
    }
}