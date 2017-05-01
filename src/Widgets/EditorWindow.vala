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


public class EditorWindow : Gtk.Box {
    public signal string? show_info_window (Gtk.TextIter start_iter);

    public Document document { get; construct; }
    public Gtk.SourceSearchSettings search_settings { get; construct; }
    public Gtk.SourceSearchContext search_context { get; construct; }
    public Gtk.SourceView source_view { get; construct; }
    public IDEBuffer source_buffer { get; construct; }
    private Gtk.SourceMap source_map;
    private Gtk.ProgressBar progress_bar;
    private Gtk.ScrolledWindow view_scrolled;
    private Cancellable? search_cancellable;

    private uint show_info_timeout_id = 0;
    private bool show_definition_tooltip = false;

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

    private class GutterReportMessageRenderer : Gtk.SourceGutterRendererPixbuf {
        construct {
            size = 16;
            xpad = 4;
            visible = true;
        }

        public override void query_data (Gtk.TextIter start, Gtk.TextIter end, Gtk.SourceGutterRendererState state) {
            var buffer = start.get_buffer () as IDEBuffer;
            if (buffer == null || buffer.recently_changed) {
                set ("pixbuf", null, null);
                return;
            }

            var document_manager = IDEApplication.get_main_window ().document_manager;
            var code_parser = document_manager.get_code_parser ();

            string? filename = buffer.document.get_filename ();
            if (filename == null) {
                set ("pixbuf", null, null);
                return;
            }

            var message = code_parser.get_report_message_at (filename, start.get_line () + 1);
            if (message == null) {
                set ("pixbuf", null, null);
                return;
            }

            set ("icon-name", "%s-symbolic".printf (message.to_icon_name ()));
        }
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        expand = true;
        has_tooltip = true;

        source_buffer = new IDEBuffer (document, null);
        search_settings = new Gtk.SourceSearchSettings ();
        search_context = new Gtk.SourceSearchContext (source_buffer, search_settings);
        search_context.highlight = true;

        var red = Gdk.RGBA () {
            red = 1,
            green = 0.2,
            blue = 0.4,
            alpha = 1
        };

        var yellow = Gdk.RGBA () {
            red = 1,
            green = 0.9,
            blue = 0.2,
            alpha = 1
        };

        var blue = Gdk.RGBA () {
            red = 0.5,
            green = 0.8,
            blue = 1,
            alpha = 1
        };

        source_buffer.create_tag ("error-tag", "underline", Pango.Underline.ERROR, "underline-rgba", red);
        source_buffer.create_tag ("warning-tag", "underline", Pango.Underline.ERROR, "underline-rgba", yellow);
        source_buffer.create_tag ("info-tag", "underline", Pango.Underline.LOW, "underline-rgba", blue);

        source_buffer.highlight_syntax = true;

        var settings = IDESettings.get_default ();

        source_view = new Gtk.SourceView.with_buffer (source_buffer);
        source_view.add_events (Gdk.EventMask.STRUCTURE_MASK);
        source_view.override_font (Pango.FontDescription.from_string (settings.font_desc));

        source_view.show_right_margin = false;
        source_view.smart_backspace = true;
        source_view.smart_home_end = Gtk.SourceSmartHomeEndType.BEFORE;
        source_view.tab_width = 4;
        source_view.completion.select_on_show = true;
        source_view.completion.show_icons = true;
        source_view.completion.remember_info_visibility = true;
        source_view.left_margin = 6;
        source_view.motion_notify_event.connect (on_motion_notify_event);
        if (settings.draw_spaces_tabs) {
            source_view.draw_spaces = Gtk.SourceDrawSpacesFlags.SPACE | Gtk.SourceDrawSpacesFlags.LEADING | Gtk.SourceDrawSpacesFlags.TAB;
        } else {
            source_view.draw_spaces = 0;
        }            

        progress_bar = new Gtk.ProgressBar ();
        progress_bar.show_text = false;  
        progress_bar.halign = Gtk.Align.START;
        progress_bar.valign = Gtk.Align.START;
        Utils.set_widget_visible (progress_bar, false);

        view_scrolled = new Gtk.ScrolledWindow (null, null);
        view_scrolled.add (source_view);

        var label = new Gtk.Label (null);
        label.opacity = 0.7;
        label.halign = Gtk.Align.END;
        label.valign = Gtk.Align.END;

        var overlay = new Gtk.Overlay ();
        overlay.add (view_scrolled);
        overlay.add_overlay (progress_bar);

        source_map = new Gtk.SourceMap ();
        source_map.set_view (source_view);

        var map_revealer = new Gtk.Revealer ();
        map_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
        map_revealer.add (source_map);

        var editor_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        editor_container.pack_start (overlay, true, true, 0);
        editor_container.pack_start (map_revealer, false, true, 0);

        var report_message_renderer = new GutterReportMessageRenderer ();

        var gutter = source_view.get_gutter (Gtk.TextWindowType.LEFT);
        gutter.insert (report_message_renderer, -100);

        pack_start (editor_container, true, true, 0);

        var schema = settings.schema;
        schema.bind ("show-line-numbers", source_view, "show-line-numbers", SettingsBindFlags.DEFAULT);
        schema.bind ("show-mini-map", map_revealer, "reveal-child", SettingsBindFlags.DEFAULT);
        schema.bind ("highlight-current-line", source_view, "highlight-current-line", SettingsBindFlags.DEFAULT);
        schema.bind ("highlight-syntax", source_buffer, "highlight-syntax", SettingsBindFlags.DEFAULT);
        schema.bind ("highlight-matching-brackets", source_buffer, "highlight-matching-brackets", SettingsBindFlags.DEFAULT);
        schema.bind ("tabs-to-spaces", source_view, "insert-spaces-instead-of-tabs", SettingsBindFlags.DEFAULT);
        settings.notify["font-desc"].connect (() => {
            source_view.override_font (Pango.FontDescription.from_string (settings.font_desc));
        });

        settings.notify["draw-spaces-tabs"].connect (() => {
            if (settings.draw_spaces_tabs) {
                source_view.draw_spaces = Gtk.SourceDrawSpacesFlags.SPACE | Gtk.SourceDrawSpacesFlags.LEADING | Gtk.SourceDrawSpacesFlags.TAB;
            } else {
                source_view.draw_spaces = 0;
            }
        });        
    }

    public EditorWindow (Document document) {
        Object (document: document);
    }

    public override bool query_tooltip (int x, int y, bool keyboard_tooltip, Gtk.Tooltip tooltip) {
        if (!show_definition_tooltip) {
            return false;
        }

        show_definition_tooltip = false;
        return base.query_tooltip (x, y, keyboard_tooltip, tooltip);
    }

    public void set_language (Gtk.SourceLanguage lang) {
        source_buffer.set_language (lang);
    }

    public Gtk.SourceLanguage get_language () {
        return source_buffer.get_language ();
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

    public async void search (string query, bool regex, bool case_sensitive, bool word_boundaries) {
        search_cancellable = new Cancellable ();

        search_settings.search_text = query;
        search_settings.regex_enabled = regex;
        search_settings.case_sensitive = case_sensitive;
        search_settings.at_word_boundaries = word_boundaries;            

        Gtk.TextIter start_iter, end_iter;
        source_buffer.get_start_iter (out start_iter);

        try {
            bool found = yield search_context.forward_async (start_iter, search_cancellable, out start_iter, out end_iter);
            if (found) {
                source_buffer.select_range (start_iter, end_iter);
                source_view.scroll_to_iter (start_iter, 0, false, 0, 0);
            }   
        } catch (Error e) {
            warning (e.message);
        }
    }

    public async void replace (string replace_query) {
        Gtk.TextIter start_iter, end_iter;
        source_buffer.get_iter_at_offset (out start_iter, source_buffer.cursor_position);

        try {
            bool found = yield search_context.forward_async (start_iter, search_cancellable, out start_iter, out end_iter);
            if (found) {
                search_context.replace (start_iter, end_iter, replace_query, replace_query.length);
                yield search_next ();
            }
        } catch (Error e) {
            warning (e.message);
        }
    }

    public void replace_all (string replace_query) {
        try {
            search_context.replace_all (replace_query, replace_query.length);
        } catch (Error e) {
            warning (e.message);
        }
    }

    public async void search_previous () {
        search_cancellable = new Cancellable ();

        Gtk.TextIter start_iter, end_iter;
        source_buffer.get_selection_bounds (out start_iter, out end_iter);

        try {
            bool found = yield search_context.backward_async (start_iter, search_cancellable, out start_iter, out end_iter);
            if (found) {
                source_buffer.select_range (start_iter, end_iter);
                source_view.scroll_to_iter (start_iter, 0, false, 0, 0);
            }
        } catch (Error e) {
            warning (e.message);
        }
    }

    public async void search_next () {
        search_cancellable = new Cancellable ();
        
        Gtk.TextIter start_iter, end_iter;
        source_buffer.get_selection_bounds (out start_iter, out end_iter);

        try {
            bool found = yield search_context.forward_async (end_iter, search_cancellable, out start_iter, out end_iter);
            if (found) {
                source_buffer.select_range (start_iter, end_iter);
                source_view.scroll_to_iter (start_iter, 0, false, 0, 0);
            }
        } catch (Error e) {
            warning (e.message);
        }
    }

    public void cancel_search () {
        if (search_cancellable != null && !search_cancellable.is_cancelled ()) {
            search_cancellable.cancel ();
        }
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
            case ReportType.ERROR:
                source_buffer.apply_tag_by_name ("error-tag", start_iter, end_iter);
                break;
            case ReportType.WARNING:
                source_buffer.apply_tag_by_name ("warning-tag", start_iter, end_iter);
                break;
            case ReportType.NOTE:
                source_buffer.apply_tag_by_name ("info-tag", start_iter, end_iter);
                break;
        }
    }

    public void set_buffer (Gtk.TextBuffer buffer) {
        source_view.set_buffer (buffer);
    }

    public Gtk.SourceBuffer get_buffer () {
        return (Gtk.SourceBuffer)source_view.get_buffer ();
    }

    private bool on_motion_notify_event (Gdk.EventMotion event) {
        if (show_info_timeout_id > 0) {
            Source.remove (show_info_timeout_id);
            show_info_timeout_id = 0;
        }

        show_info_timeout_id = Timeout.add (400, () => {
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

        Gtk.TextIter start_buffer_iter;
        source_buffer.get_start_iter (out start_buffer_iter);
        if (start_buffer_iter.compare (start_iter) == 0) {
            return false;
        }

        Gtk.TextIter end_iter = Gtk.TextIter ();
        end_iter.assign (start_iter);
        end_iter.forward_to_line_end ();

        if (end_iter.get_line () > start_iter.get_line ()
            || source_buffer.get_text (start_iter, end_iter, false).strip () == ""
            || end_iter.get_line_offset () <= start_iter.get_line_offset ()) {
            return false;
        }

        string? definition = show_info_window (start_iter);
        show_definition_tooltip = true;
        tooltip_text = definition;

        return false;
    }
}
