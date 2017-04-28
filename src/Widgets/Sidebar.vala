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


public class Sidebar : Gtk.Box {        
    public FileSearchView file_search_view { get; construct; }
    public SourceList source_list { get; construct; }

    private Gtk.Stack sidebar_stack;
    private Gtk.SearchEntry search_entry;
    private Gtk.ToggleButton document_toogle_button;

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        file_search_view = new FileSearchView ();

        source_list = new SourceList ();
        source_list.set_filter_func (source_list_visible_func, true);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.min_content_width = 200;
        scrolled.add (source_list);

        sidebar_stack = new Gtk.Stack ();
        sidebar_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT;
        sidebar_stack.add_named (scrolled, Constants.FILE_SIDEBAR_VIEW_NAME);
        sidebar_stack.add_named (file_search_view, Constants.FILE_SEARCH_VIEW_NAME);
        sidebar_stack.visible_child_name = Constants.FILE_SIDEBAR_VIEW_NAME;

        search_entry = new Gtk.SearchEntry ();
        search_entry.hexpand = true;
        search_entry.placeholder_text = _("Search files…");
        search_entry.search_changed.connect (on_search_entry_changed);

        var search_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        search_box.margin = 6;

        document_toogle_button = new Gtk.ToggleButton ();
        document_toogle_button.tooltip_text = _("Search in document content");
        document_toogle_button.get_style_context ().add_class ("flat");
        document_toogle_button.image = new Gtk.Image.from_icon_name ("x-office-document-symbolic", Gtk.IconSize.MENU);
        document_toogle_button.toggled.connect (on_search_entry_changed);

        search_box.pack_start (search_entry, true, true);
        search_box.pack_end (document_toogle_button, false, false);

        add (search_box);
        add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        add (sidebar_stack);
    }

    private bool source_list_visible_func (Granite.Widgets.SourceList.Item item) {
        if (item is SourceList.FileItem) {
            return item.name.down ().contains (search_entry.text.down ());
        }

        return true;
    }       

    private void on_search_entry_changed () {
        if (search_entry.text != "") {
            file_search_view.search.begin (search_entry.text, document_toogle_button.active);
            sidebar_stack.visible_child_name = Constants.FILE_SEARCH_VIEW_NAME;
        } else {
            sidebar_stack.visible_child_name = Constants.FILE_SIDEBAR_VIEW_NAME;
        }
    }
}