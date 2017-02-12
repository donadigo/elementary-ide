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
    public class ProjectView : Gtk.Box, DocumentManager {
        public signal void update_toolbar ();

        private const Gtk.TargetEntry[] targets = {{ "text/uri-list", 0, 0 }};

        private ValaCodeParser code_parser;

        private Project project;

        private Gee.ArrayList<EditorView> editors;
        private int current_editor_index = 0;

        private Sidebar sidebar;
        private Gtk.Paned vertical_paned;
        private SymbolTreeView symbol_tree_view;

        private SearchToolbar document_search_toolbar;

        private InfoWindow info_window;

        private ValaDocumentProvider vala_provider;
        private Gtk.SourceCompletionWords words_provider;

        private BottomStack bottom_stack;

        private uint update_report_view_timeout_id = 0;

        construct {
            orientation = Gtk.Orientation.VERTICAL;

            code_parser = new ValaCodeParser ();

            vala_provider = new ValaDocumentProvider (this);

            words_provider = new Gtk.SourceCompletionWords (_("Word Completion"), null);
            words_provider.activation = Gtk.SourceCompletionActivation.INTERACTIVE | Gtk.SourceCompletionActivation.USER_REQUESTED;
            words_provider.interactive_delay = 100;
            words_provider.minimum_word_size = 2;
            words_provider.priority = 1;

            editors = new Gee.ArrayList<EditorView> ();

            document_search_toolbar = new SearchToolbar ();
            document_search_toolbar.request_search_replace.connect (on_request_search_replace);
            document_search_toolbar.request_go_up.connect (on_request_go_up);
            document_search_toolbar.request_go_down.connect (on_request_go_down);

            // TODO: make this a Gtk.Paned to have a split view
            var editors_container = new Gtk.Grid ();

            var top_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            top_box.add (document_search_toolbar);
            top_box.add (editors_container);

            var main_editor = create_new_editor_view ();
            editors.add (main_editor);
            editors_container.add (main_editor);

            Gtk.drag_dest_set (editors_container, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY);
            editors_container.drag_data_received.connect (on_drag_data_received);

            bottom_stack = new BottomStack ();
            bottom_stack.report_widget.jump_to.connect (on_jump_to);

            sidebar = new Sidebar ();
            sidebar.file_search_view.result_activated.connect (on_result_activated);
            sidebar.source_list.item_selected.connect (on_file_item_selected);

            symbol_tree_view = new SymbolTreeView ();
            symbol_tree_view.symbol_selected.connect (on_symbol_selected);
            symbol_tree_view.width_request = 100;

            info_window = new InfoWindow ();

            vertical_paned = new Gtk.Paned (Gtk.Orientation.VERTICAL);
            vertical_paned.pack1 (top_box, true, false);
            vertical_paned.pack2 (bottom_stack, false, false);

            var horizontal_paned1 = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            horizontal_paned1.pack1 (sidebar, false, false);
            horizontal_paned1.pack2 (vertical_paned, true, true);

            // GTK+, please :/
            var horizontal_paned2 = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            horizontal_paned2.pack1 (horizontal_paned1, true, true);
            horizontal_paned2.pack2 (symbol_tree_view, false, false);

            update_report_view_timeout_id = Timeout.add (2000, update_project_view_func);

            add (horizontal_paned2);
            show_all ();
        }

        public void load_project (Project? project) {
            this.project = project;

            if (project == null) {
                Utils.set_widget_visible (sidebar, false);
                bottom_stack.terminal_widget.spawn_default (Environment.get_home_dir ());
                return;
            }

            Utils.set_widget_visible (sidebar, true);
            sidebar.source_list.set_file (File.new_for_path (project.root_path));

            code_parser = new ValaCodeParser ();

            foreach (string package in project.packages) {
                code_parser.add_package (package);
            }

            foreach (string source in project.sources) {
                code_parser.add_source (source);
            }

            sidebar.file_search_view.set_search_directory (project.root_path);

            bottom_stack.terminal_widget.clear ();
            bottom_stack.terminal_widget.spawn_default (project.root_path);

            project.save ();      
            code_parser.queue_parse ();
            update_project_view ();
        }

        public void toggle_search () {
            document_search_toolbar.reveal_child = !document_search_toolbar.reveal_child;
        }

        public Project? get_project () {
            return project;
        }

        private EditorView get_current_editor_view () {
            return editors[current_editor_index];
        }

        private EditorView create_new_editor_view () {
            var editor_view = new EditorView ();
            editor_view.new_tab_requested.connect (add_new_document);
            editor_view.tab_switched.connect (on_tab_switched);
            editor_view.document_removed.connect (on_document_removed);
            return editor_view;
        }

        private void on_request_search_replace (string query, string replace_query, bool regex, bool case_sensitive, bool word_boundaries, SearchMode mode) {
            var document = get_current_document ();
            if (document == null) {
                return;
            }

            var editor_window = document.editor_window;
            switch (mode) {
                case SearchMode.SEARCH_ONLY:
                    editor_window.cancel_search ();
                    editor_window.search.begin (query, regex, case_sensitive, word_boundaries, (obj, res) => {
                        editor_window.search.end (res);
                        update_search_match_count ();
                    });
                    
                    break;
                case SearchMode.REPLACE:
                    editor_window.replace.begin (replace_query, (obj, res) => {
                        editor_window.replace.end (res);
                        update_search_match_count ();
                    });

                    break;
                case SearchMode.REPLACE_ALL:
                    editor_window.replace_all (replace_query);
                    break;
                default:
                    break;
            }
        }

        private void on_request_go_up () {
            var document = get_current_document ();
            if (document == null) {
                return;
            }

            var editor_window = document.editor_window;            
            editor_window.cancel_search ();
            editor_window.search_previous.begin ((obj, res) => {
                editor_window.search_previous.end (res);
                update_search_match_count ();
            });
        }

        private void on_request_go_down () {
            var document = get_current_document ();
            if (document == null) {
                return;
            }

            var editor_window = document.editor_window;            
            editor_window.cancel_search ();
            editor_window.search_next.begin ((obj, res) => {
                editor_window.search_next.end (res);
                update_search_match_count ();
            });
            
        }

        private void on_result_activated (FileSearchResult result) {
            if (result.search_location != null) {
                on_jump_to (result.filename, result.search_location.location.line - 1, 0);
            } else {
                open_focus_filename (result.filename);
            }
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

        private void on_file_item_selected (Granite.Widgets.SourceList.Item? item) {
            if (item == null || !(item is SourceList.FileItem)) {
                return;
            }

            string filename = ((SourceList.FileItem)item).filename;
            open_focus_filename (filename);
        }

        private void on_symbol_selected (SymbolTreeView.SymbolItem item) {
            var sr = item.symbol.source_reference;
            if (sr == null) {
                return;
            }

            on_jump_to (sr.file.filename, sr.begin.line - 1, sr.begin.column);
        }

        private void on_jump_to (string filename, int line, int column) {
            var document = open_focus_filename (filename);

            // Wait for the textview to compute line heights
            Idle.add (() => {
                var source_buffer = document.editor_window.source_buffer;

                Gtk.TextIter iter;
                source_buffer.get_iter_at_mark (out iter, source_buffer.get_insert ());

                iter.set_line (line);
                iter.set_line_offset (column);
                
                document.editor_window.source_buffer.place_cursor (iter);
                document.editor_window.source_view.scroll_to_iter (iter, 0.4, true, 0, 0);
                return false;
            });
        }

        private Document open_focus_filename (string filename) {
            var document = get_document_by_filename (filename);
            if (document == null) {
                document = new Document (File.new_for_path (filename), project);
                add_document (document, true);
            } else {
                get_current_editor_view ().notebook.current = document;
            }

            Idle.add (() => {
                document.grab_focus ();
                return false;
            });

            return document;
        }

        public void add_new_document () {
            var document = new Document.empty ();
            add_document (document, true);
        }

        private void on_tab_switched (Granite.Widgets.Tab? old_tab, Granite.Widgets.Tab new_tab) {
            update_location_label ();
            update_symbol_tree ();
            current_document_changed ();
        }

        private void on_document_removed (EditorView editor_view, Document document) {
            editor_view.remove_document (document);
            remove_document_internal (document);

            update_location_label ();
            update_toolbar ();
        }

        public void add_document (Document document, bool focus = true) {
            document.load.begin ();

            words_provider.register (document.editor_window.source_buffer);

            document.add_provider (vala_provider);
            document.add_provider (words_provider);

            document.content_changed.connect (() => document_content_changed (document));

            var editor_window = document.editor_window;

            editor_window.source_buffer.notify["cursor-position"].connect (update_location_label);
            editor_window.search_context.notify["occurrences-count"].connect (update_search_match_count);
            editor_window.close_info_window.connect (on_close_info_window);
            editor_window.show_info_window.connect ((iter, x, y) => on_show_info_window (document, iter, x, y));

            get_current_editor_view ().add_document (document, focus);
            update_location_label ();
            update_toolbar ();
        }

        private void remove_document_internal (Document document) {
            words_provider.unregister (document.editor_window.source_buffer);          
        }

        public Gee.List<Document> get_opened_documents () {
            var list = new Gee.ArrayList<Document> ();
            foreach (var editor in editors) {  
                foreach (var tab in editor.notebook.tabs) {
                    var document = tab as Document;
                    if (document == null) {
                        continue;
                    }

                    list.add (document);
                }
            }

            return list;
        }

        public Document? get_current_document () {
            return get_current_editor_view ().notebook.current as Document;
        }

        public CodeParser get_code_parser () {
            return code_parser;
        }

        private void document_content_changed (Document document) {
            code_parser.update_document_content (document);
        }

        private bool update_project_view_func () {
            if (code_parser.parsing) {
                return true;
            }

            var document = get_current_document ();
            if (document != null) {
                if (!document.recently_changed) {
                    return true;
                } else {
                    document.recently_changed = false;
                }
            }

            code_parser.queue_parse ();
            Idle.add (() => {
                update_project_view ();
                return false;
            });

            return true;
        }

        private void update_project_view () {
            update_report_widget (code_parser.report);  
            update_view_tags (code_parser.report); 
            update_symbol_tree ();
        }

        private void update_location_label () {
            var current = get_current_document ();
            if (current == null) {
                Utils.set_widget_visible (bottom_stack.location_label, false);
                return;
            }

            bottom_stack.location_label.label = _("Line %i, Column %i".printf (current.current_line + 1, current.current_column));
            Utils.set_widget_visible (bottom_stack.location_label, true);
        }

        private void update_report_widget (Report report) {
            int errors, warnings;
            report.get_message_count (out errors, out warnings);

            bottom_stack.report_label.label = _("Errors: %i, Warnings: %i".printf (errors, warnings));

            bottom_stack.report_widget.clear ();
            bottom_stack.report_widget.set_report (report);
        }

        private void update_view_tags (Report report) {
            clear_view_tags ();

            foreach (var message in report.get_messages ()) {
                if (message.source == null) {
                    continue;
                }

                var document = get_document_by_filename (message.source.file.filename);
                if (document != null) {
                    document.editor_window.apply_report_message (message);
                }
            }
        }

        private void clear_view_tags () {
            foreach (var document in get_opened_documents ()) {
                document.editor_window.reset_report_tags ();
            }
        }

        private void update_symbol_tree () {
            symbol_tree_view.clear ();

            var document = get_current_document ();
            if (document == null) {
                return;
            }

            var symbols = code_parser.get_symbols (document.get_file_path ());
            symbol_tree_view.add_symbols (symbols);

            code_parser.clear_symbol_tree ();
        }

        private Document? get_document_by_filename (string filename) {
            foreach (var document in get_opened_documents ()) {
                if (document.get_file_path () == filename) {
                    return document;
                }
            }

            return null;
        }

        private void update_search_match_count () {
            var document = get_current_document ();
            if (document == null) {
                return;
            }

            var search_context = document.editor_window.search_context;

            Gtk.TextIter start_iter, end_iter;
            search_context.buffer.get_selection_bounds (out start_iter, out end_iter);

            int occurrence = search_context.get_occurrence_position (start_iter, end_iter);
            document_search_toolbar.set_match_count_label (occurrence, search_context.occurrences_count);
        }

        private void on_show_info_window (Document document, Gtk.TextIter start_iter, int x, int y) {
            var symbol = code_parser.lookup_symbol_at (document.get_file_path (), start_iter.get_line () + 1, start_iter.get_line_offset ());
            if (symbol == null || symbol.name == null) {
                return;
            }        

            string definition = code_parser.write_symbol_definition (symbol).strip ();
            if (definition != "") {
                info_window.set_label (definition);
                info_window.show_at (x, y);    
            }
        }

        private void on_close_info_window () {
            info_window.hide ();
        }
    }
}