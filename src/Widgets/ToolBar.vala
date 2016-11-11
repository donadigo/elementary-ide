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
    public class ToolBar : Gtk.HeaderBar {
        public bool show_editor_buttons {
            set {
                Utils.set_widget_visible (open_button, value);
                Utils.set_widget_visible (new_button, value);
                Utils.set_widget_visible (save_button, value);
                Utils.set_widget_visible (run_button, value);
                Utils.set_widget_visible (search_button, value);
            }
        }

        public signal void open_project ();
        public signal void open_files ();
        public signal void save_current_document ();
        public signal void save_opened_documents ();
        public signal void toggle_search ();

        private Gtk.Button new_button;
        private Gtk.Button preferences_button;
        private Gtk.ToggleButton search_button;

    	private MenuButton open_button;
        private MenuButton save_button;
        private MenuButton run_button;

        private EditorPreferencesDialog ep_dialog;

        construct {
            show_close_button = true;

            new_button = new Gtk.Button.from_icon_name ("document-new", Gtk.IconSize.LARGE_TOOLBAR);
            new_button.tooltip_text = _("New class");
            new_button.clicked.connect (show_new_file_dialog);
            add (new_button);

            open_button = new MenuButton (_("Open"), "document-open");
            add (open_button);

            save_button = new MenuButton (_("Save"), "document-save");
            add (save_button);

            ep_dialog = new EditorPreferencesDialog ();

            preferences_button = new Gtk.Button.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
            preferences_button.clicked.connect (() => ep_dialog.show_all ());
            pack_end (preferences_button);

            run_button = new MenuButton (_("Build & Run"), "media-playback-start");
            add (run_button);

            var image = new Gtk.Image.from_icon_name ("edit-find", Gtk.IconSize.LARGE_TOOLBAR);

            search_button = new Gtk.ToggleButton ();
            search_button.toggled.connect (() => toggle_search ());
            search_button.image = image;

            pack_end (search_button);

            // TODO: change sensitivity of menu items
            var menu_item = run_button.add_menu_item (_("Only build"));
            menu_item.activate.connect (build);

            menu_item = run_button.add_menu_item (_("Build & run"));

            menu_item = open_button.add_menu_item (_("Open project"));
            menu_item.activate.connect (() => open_project ());

            menu_item = open_button.add_menu_item (_("Open files"));
            menu_item.activate.connect (() => open_files ());

            menu_item = save_button.add_menu_item (_("Save current document"));
            menu_item.activate.connect (() => save_current_document ());

            menu_item = save_button.add_menu_item (_("Save all opened documents"));
            menu_item.activate.connect (() => save_opened_documents ());
        }

        private void build () {

        }

        private void show_new_file_dialog () {
            new_button.sensitive = false;

            var new_file_dialog = new NewFileDialog ();
            new_file_dialog.show_all ();
            new_file_dialog.hide.connect (() => new_button.sensitive = true);
        }
    }
}