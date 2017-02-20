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
    public enum SearchMode {
        SEARCH_ONLY = 0,
        REPLACE,
        REPLACE_ALL
    }

    public class SearchToolbar : Gtk.Revealer {
        public signal void request_search_replace (string query, string replace_query, bool regex, bool case_sensitive, bool word_boundaries, SearchMode mode);
        public signal void request_go_down ();
        public signal void request_go_up ();

        private Gtk.SearchEntry search_entry;
        private Gtk.Entry replace_entry;
        private Gtk.ToggleToolButton regex_button;
        private Gtk.ToggleToolButton cs_button;
        private Gtk.ToggleToolButton wb_button;
        private Gtk.ToolButton down_button;
        private Gtk.ToolButton up_button;
        private Gtk.Label matches_label;

        construct {
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;

            search_entry = new Gtk.SearchEntry ();
            search_entry.placeholder_text = _("Search");
            search_entry.changed.connect (on_search_entry_changed);

            var search_entry_item = new Gtk.ToolItem ();
            search_entry_item.margin_end = 3;
            search_entry_item.add (search_entry);

            replace_entry = new Gtk.Entry ();
            replace_entry.placeholder_text = _("Replace With");
            replace_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.PRIMARY, "edit-symbolic");

            var replace_entry_item = new Gtk.ToolItem ();
            replace_entry_item.margin_end = 3;
            replace_entry_item.add (replace_entry);

            regex_button = new Gtk.ToggleToolButton ();
            regex_button.icon_name = "insert-object-symbolic";
            regex_button.notify["active"].connect (() => send_search_request ());
            regex_button.tooltip_text = _("Regular expression");
            regex_button.set_homogeneous (false);

            cs_button = new Gtk.ToggleToolButton ();
            cs_button.icon_name = "format-text-larger-symbolic";
            cs_button.notify["active"].connect (() => send_search_request ());
            cs_button.tooltip_text = _("Case sensitive");
            cs_button.set_homogeneous (false);

            wb_button = new Gtk.ToggleToolButton ();
            wb_button.icon_name = "view-dual-symbolic";
            wb_button.notify["active"].connect (() => send_search_request ());
            wb_button.tooltip_text = _("Search only within word boundaries");
            wb_button.set_homogeneous (false);

            down_button = new Gtk.ToolButton (null, null);
            down_button.icon_name = "go-down-symbolic";
            down_button.clicked.connect (() => request_go_down ());
            down_button.tooltip_text = _("Next");
            down_button.set_homogeneous (false);

            up_button = new Gtk.ToolButton (null, null);
            up_button.icon_name = "go-up-symbolic";
            up_button.clicked.connect (() => request_go_up ());
            up_button.tooltip_text = _("Previous");
            up_button.set_homogeneous (false);

            matches_label = new Gtk.Label (null);

            var matches_label_item = new Gtk.ToolItem ();
            matches_label_item.margin_end = 3;
            matches_label_item.halign = Gtk.Align.END;
            matches_label_item.add (matches_label);

            var replace_button = new Gtk.ToolButton (null, _("Replace"));
            replace_button.clicked.connect (() => send_search_request (SearchMode.REPLACE));

            var replace_all_button = new Gtk.ToolButton (null, _("Replace All"));
            replace_all_button.clicked.connect (() => send_search_request (SearchMode.REPLACE_ALL));

            var spacer = new Gtk.ToolItem ();
            spacer.set_expand (true);

            var toolbar = new Gtk.Toolbar ();
            toolbar.icon_size = Gtk.IconSize.SMALL_TOOLBAR;
            toolbar.get_style_context ().add_class ("search-bar");
            toolbar.add (search_entry_item);
            toolbar.add (replace_entry_item);
            toolbar.add (regex_button);
            toolbar.add (cs_button);
            toolbar.add (wb_button);
            toolbar.add (down_button);
            toolbar.add (up_button);
            toolbar.add (replace_button);
            toolbar.add (replace_all_button);
            toolbar.add (spacer);
            toolbar.add (matches_label_item);
            add (toolbar);

            notify["reveal-child"].connect (on_child_reveal);

            Utils.set_widget_visible (matches_label, false);
        }

        public void set_match_count_label (int occurrence, int matches) {
            matches_label.label = _("%i of %i matches").printf (occurrence, matches);
        }

        private void on_search_entry_changed () {
            Utils.set_widget_visible (matches_label, search_entry.text != "");
            send_search_request ();
        }

        private void send_search_request (SearchMode mode = SearchMode.SEARCH_ONLY) {
            request_search_replace (search_entry.text,
                                    replace_entry.text,
                                    regex_button.active,
                                    cs_button.active,
                                    wb_button.active,
                                    mode);
        }

        private void on_child_reveal () {
            if (reveal_child) {
                search_entry.grab_focus ();
            }
        }
    }
}