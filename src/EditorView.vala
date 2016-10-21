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
    public class EditorView : Gtk.Box, DocumentManager {
        private const Gtk.TargetEntry[] targets = {{ "text/uri-list", 0, 0 }};

        private ValaCodeParser code_parser;

        private Project project;
        private Gee.ArrayList<Document> documents;

        private TerminalWidget terminal_widget;

        private Granite.Widgets.DynamicNotebook notebook;
        private SourceList source_list;
        private Gtk.Paned vertical_paned;

        private Gtk.Label location_label;

        private ReportWidget report_widget;
        public InfoWindow info_window;

        private ValaDocumentProvider provider;

        private Granite.Widgets.ModeButton mode_button;
        private Granite.Widgets.AlertView no_documents_view;
        private Gtk.Stack notebook_stack;
        private Gtk.Stack bottom_stack;

        private bool document_recently_changed = false;
        private uint update_report_view_timeout_id = 0;

        private int report_widget_id = -1;
        private int terminal_widget_id = -1;
        private int build_output_widget_id = -1;

        construct {
            orientation = Gtk.Orientation.VERTICAL;

            code_parser = new ValaCodeParser ();
            provider = new ValaDocumentProvider (this);

            documents = new Gee.ArrayList<Document> ();

            terminal_widget = new TerminalWidget ();

            no_documents_view = new Granite.Widgets.AlertView (_("No documents opened"), _("Open a document to begin editing"), "dialog-information");
            no_documents_view.visible = true;

            notebook = new Granite.Widgets.DynamicNotebook ();
            notebook.visible = true;
            notebook.expand = true;
            notebook.show_tabs = true;
            notebook.allow_drag = true;
            notebook.allow_pinning = true;
            notebook.allow_new_window = true;
            notebook.allow_duplication = false;
            notebook.add_button_visible = true;
            notebook.new_tab_requested.connect (add_new_document);
            notebook.tab_switched.connect (on_tab_switched);
            notebook.tab_removed.connect (on_tab_removed);
            notebook.add_button_tooltip = _("New empty document");

            notebook_stack = new Gtk.Stack ();
            notebook_stack.add_named (no_documents_view, Constants.NO_DOCUMENTS_VIEW_NAME);
            notebook_stack.add_named (notebook, Constants.NOTEBOOK_VIEW_NAME);

            Gtk.drag_dest_set (notebook_stack, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY);
            notebook_stack.drag_data_received.connect (on_drag_data_received);

            location_label = new Gtk.Label (null);

            var info_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            info_box.add (location_label);

            source_list = new SourceList ();
            source_list.item_selected.connect (on_item_selected);

            info_window = new InfoWindow ();

            report_widget = new ReportWidget ();
            report_widget.jump_to.connect (on_jump_to);

            var bottom_bar = new Gtk.Grid ();

            bottom_stack = new Gtk.Stack ();
            bottom_stack.transition_type = Gtk.StackTransitionType.OVER_RIGHT_LEFT;
            bottom_stack.add_named (report_widget, Constants.REPORT_VIEW_NAME);
            bottom_stack.add_named (terminal_widget, Constants.TERMINAL_VIEW_NAME);

            mode_button = new Granite.Widgets.ModeButton ();
            mode_button.mode_changed.connect (on_mode_changed);
            mode_button.orientation = Gtk.Orientation.VERTICAL;
            mode_button.valign = Gtk.Align.START;

            report_widget_id = mode_button.append_icon ("dialog-information-symbolic", Gtk.IconSize.MENU);
            terminal_widget_id = mode_button.append_icon ("utilities-terminal-symbolic", Gtk.IconSize.MENU);
            build_output_widget_id = mode_button.append_icon ("open-menu-symbolic", Gtk.IconSize.MENU);

            style_mode_button_children ();

            mode_button.selected = report_widget_id;

            bottom_bar.attach (mode_button, 0, 0, 1, 1);
            bottom_bar.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 1, 0, 1, 1);
            bottom_bar.attach (bottom_stack, 2, 0, 1, 1);

            var scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled.min_content_width = 200;
            scrolled.add (source_list);

            vertical_paned = new Gtk.Paned (Gtk.Orientation.VERTICAL);
            vertical_paned.pack1 (notebook_stack, true, false);
            vertical_paned.pack2 (bottom_bar, false, false);

            var horizontal_paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            horizontal_paned.pack1 (scrolled, false, false);
            horizontal_paned.pack2 (vertical_paned, true, true);

            update_report_view_timeout_id = Timeout.add (2000, update_report_view);

            add (horizontal_paned);
            show_all ();

            update_notebook_stack ();
        }

        public void set_info_window_transient (Gtk.Window window) {
            info_window.transient_for = window;
        }

        public void set_project (Project? project) {
            this.project = project;

            // TODO: clear previous project
            if (project == null) {
                return;
            }

            source_list.set_file (File.new_for_path (project.root_path));

            code_parser = new ValaCodeParser ();

            foreach (string package in project.packages) {
                code_parser.add_package (package);
            }

            foreach (string source in project.sources) {
                code_parser.add_source (source);
            }

            terminal_widget.spawn_default (project.root_path);
            project.save ();      
            queue_parse ();     
        }

        public void add_new_document () {
            var document = new Document.empty ();
            add_document (document, true);
        }

        private bool update_report_view () {
            clear_view_tags ();
            if (code_parser.parsing) {
                return true;
            }

            if (document_recently_changed) {
                document_recently_changed = false;
                return true;
            }

            update_report_widget (code_parser.report);
            update_view_tags (code_parser.report);
            return true;
        }

        private void on_drag_data_received (Gdk.DragContext ctx, int x, int y, Gtk.SelectionData sel,  uint info, uint time) {
            foreach (string uri in sel.get_uris ()) {
                try {
                    open_focus_filename (Filename.from_uri (uri));
                } catch (Error e) {
                    warning (e.message);
                }
            }

            Gtk.drag_finish (ctx, true, false, time);
        }

        private void on_mode_changed () {
            if (mode_button.selected == report_widget_id) {
                bottom_stack.visible_child_name = Constants.REPORT_VIEW_NAME;
            } else if (mode_button.selected == terminal_widget_id) {
                bottom_stack.visible_child_name = Constants.TERMINAL_VIEW_NAME;
            }
        }

        private void style_mode_button_children () {
            foreach (var child in mode_button.get_children ()) {
                if (child is Gtk.ToggleButton) {
                    child.get_style_context ().add_class ("ide-bottom-view");
                }
            }
        }

        private void on_item_selected (Granite.Widgets.SourceList.Item? item) {
            if (item == null || !(item is SourceList.FileItem)) {
                return;
            }

            string filename = ((SourceList.FileItem)item).filename;
            open_focus_filename (filename);
        }

        private void on_jump_to (string filename, int line, int column) {
            var document = open_focus_filename (filename);
            document.grab_focus ();

            // Wait for the textview to compute line heights
            Idle.add (() => {
                var source_buffer = document.editor_window.source_buffer;

                Gtk.TextIter iter;
                source_buffer.get_iter_at_mark (out iter, source_buffer.get_insert ());

                iter.set_line (line);
                iter.set_line_offset (column);
                
                document.editor_window.source_view.scroll_to_iter (iter, 0.4, true, 0, 0);
                document.editor_window.source_buffer.place_cursor (iter);
                return false;
            });
        }

        private Document open_focus_filename (string filename) {
            var document = get_document_by_filename (filename);
            if (document == null) {
                document = new Document (File.new_for_path (filename), null);
                add_document (document, true);
            } else {
                notebook.current = document;
            }

            return document;
        }

        private void on_tab_removed (Granite.Widgets.Tab tab) {
            var document = (Document)tab;
            remove_document (document);
        }

        private void on_tab_switched (Granite.Widgets.Tab? old_tab, Granite.Widgets.Tab new_tab) {
            update_location_label ();
            current_document_changed ();
        }

        public void remove_document (Document document) {
            update_notebook_stack ();
            update_location_label (); 
            documents.remove (document);            
        }

        public void add_document (Document document, bool focus = true) {
            document.load.begin ();

            try {
                document.editor_window.source_view.completion.add_provider (provider);
            } catch (Error e) {
                warning (e.message);
            }
            
            document.content_changed.connect (() => document_content_changed (document));

            document.editor_window.source_buffer.notify["cursor-position"].connect (() => update_location_label ());
            document.editor_window.close_info_window.connect (() => info_window.hide ());
            document.editor_window.show_info_window.connect ((iter, x, y) => on_show_info_window (document, iter, x, y));

            documents.add (document);
            notebook.insert_tab (document, -1);

            if (focus) {
                notebook.current = document;
            }

            update_notebook_stack ();
            update_location_label ();
        }

        public Gee.Collection<Document> get_opened_documents () {
            var list = new Gee.ArrayList<Document> ();
            foreach (var tab in notebook.tabs) {
                var document = (Document)tab;
                if (document == null) {
                    continue;
                }

                list.add (document);
            }

            return list;
        }

        public Document? get_current_document () {
            return (Document)notebook.current;
        }

        public CodeParser? get_code_parser () {
            return code_parser;
        }

        public Project? get_project () {
            return project;
        }

        public void queue_parse () {
            new Thread<bool> ("code-parse", () => {
                code_parser.parse ();
                return false;
            });
        }

        private void document_content_changed (Document document) {
            code_parser.update_document_content (document);
            if (!document_recently_changed) {
                queue_parse ();
            }

            document_recently_changed = true;
        }

        private void update_notebook_stack () {
            string child_name = notebook.n_tabs > 0 ? Constants.NOTEBOOK_VIEW_NAME : Constants.NO_DOCUMENTS_VIEW_NAME;

            // TODO: figure out why are there warnings about non existing children in stack
            if (notebook_stack.get_child_by_name (child_name) == null) {
                return;
            }

            notebook_stack.visible_child_name = child_name;    
        }

        private void update_location_label () {
            var current = get_current_document ();
            if (current == null) {
                Utils.set_widget_visible (report_widget.location_label, false);
                return;
            }

            report_widget.location_label.label = _("Line %i, Column %i".printf (current.current_line + 1, current.current_column));
            Utils.set_widget_visible (report_widget.location_label, true);
        }

        private void update_report_widget (Report report) {
            report_widget.clear ();
            report_widget.set_report (report);
        }

        private void clear_view_tags () {
            foreach (var document in documents) {
                document.editor_window.reset_report_tags ();
            }
        }

        private void update_view_tags (Report report) {
            foreach (var message in report.messages) {
                if (message.source == null) {
                    continue;
                }

                var document = get_document_by_filename (message.source.file.filename);
                if (document != null) {
                    document.editor_window.apply_report_message (message);
                }
            }
        }

        private Document? get_document_by_filename (string filename) {
            foreach (var document in documents) {
                if (document.get_file_path () == filename) {
                    return document;
                }
            }

            return null;
        }

        private void on_show_info_window (Document document, Gtk.TextIter start_iter, int x, int y) {
            var symbol = code_parser.lookup_symbol_at (document.get_file_path (), start_iter.get_line () + 1, start_iter.get_line_offset ());
            if (symbol == null || symbol.name == null) {
                return;
            }          

            if (info_window.set_current_symbol (symbol)) {
                info_window.show_at (x, y);    
            }
        }
    }
}