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
    public class EditorView : Gtk.Stack {
        public signal void add_new_document ();
        public signal void tab_switched (Granite.Widgets.Tab? old_tab, Granite.Widgets.Tab new_tab);
        public signal void tab_removed (Granite.Widgets.Tab tab);

        public Granite.Widgets.DynamicNotebook notebook { get; construct; }
        private Gee.ArrayList<Document> documents;

        construct {
            documents = new Gee.ArrayList<Document> ();

            notebook = new Granite.Widgets.DynamicNotebook ();
            notebook.visible = true;
            notebook.expand = true;
            notebook.show_tabs = true;
            notebook.allow_drag = true;
            notebook.allow_pinning = true;
            notebook.allow_new_window = true;
            notebook.allow_duplication = false;
            notebook.add_button_visible = true;
            notebook.new_tab_requested.connect (() => add_new_document ());
            notebook.tab_switched.connect ((old_tab, new_tab) => tab_switched (old_tab, new_tab));
            notebook.tab_removed.connect ((tab) => tab_removed (tab));
            notebook.add_button_tooltip = _("New empty document");

            var no_documents_view = new Granite.Widgets.AlertView (_("No documents opened"), _("Open a document to begin editing"), "dialog-information");
            no_documents_view.visible = true;

            add_named (no_documents_view, Constants.NO_DOCUMENTS_VIEW_NAME);
            add_named (notebook, Constants.NOTEBOOK_VIEW_NAME);
        }

        public void add_document (Document document, bool focus = true) {
            documents.add (document);
            notebook.insert_tab (document, -1);

            if (focus) {
                notebook.current = document;
            }        

            update_notebook_stack ();    
        }

        public void remove_document (Document document) {
            documents.remove (document);
            notebook.remove_tab (document);
            update_notebook_stack ();
        }

        private void update_notebook_stack () {
            visible_child_name = notebook.n_tabs > 0 ? Constants.NOTEBOOK_VIEW_NAME : Constants.NO_DOCUMENTS_VIEW_NAME;
        }
    }
}   