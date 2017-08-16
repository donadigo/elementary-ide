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
 * Authored by: Artem Anufrij <artem.anufrij@live.de>
 */

public class IDEWindow : Gtk.ApplicationWindow {
    public ProjectView document_manager { public get; private set; }

    private ToolBar toolbar;
    private Gtk.Stack main_stack;
    private Granite.Widgets.Welcome welcome;

    private BuildOptionsDialog bo_dialog;

    private int new_id = -1;
    private int open_id = -1;
    private int open_file_id = -1;

    construct {
        set_default_size (1200, 800);
        window_position = Gtk.WindowPosition.CENTER;

        document_manager = new ProjectView (); 
        document_manager.current_document_changed.connect (on_current_document_changed);

        bo_dialog = new BuildOptionsDialog ();

        toolbar = new ToolBar ();
        toolbar.build.connect (on_build);
        toolbar.rebuild.connect (on_rebuild);

        toolbar.open_project.connect (show_open_project_dialog);
        toolbar.open_files.connect (show_open_files_dialog);
        toolbar.save_current_document.connect (save_current_document);
        toolbar.save_opened_documents.connect (save_opened_documents);
        toolbar.toggle_search.connect (document_manager.toggle_search);
        toolbar.show_bo_dialog.connect (() => bo_dialog.show_all ());
        set_titlebar (toolbar);

        welcome = new Granite.Widgets.Welcome (_("Start coding"), _("Open or create a new project to start"));
        welcome.activated.connect (on_activated);
        welcome.show_all ();

        new_id = welcome.append ("document-new", "Create New Project", "Create new project from scratch");
        open_id = welcome.append ("document-open", "Open Project", "Open existing project");

        // TODO: better icon here
        open_file_id = welcome.append ("document-open", "Open Files", "Open a single or multiple files");

        main_stack = new Gtk.Stack ();
        main_stack.add_named (welcome, Constants.WELCOME_VIEW_NAME);
        main_stack.add_named (document_manager, Constants.EDITOR_VIEW_NAME);

        load_project (null);

        add (main_stack);

        on_current_document_changed ();
    }

    public IDEWindow (Gtk.Application application) {
        Object (application: application);
    }

    public override bool delete_event (Gdk.EventAny event) {
        // TODO: show dialog for unsaved documents
        foreach (var document in document_manager.get_opened_documents ()) {
            document_manager.remove_document (document);
        }

        var project = document_manager.get_project ();
        if (project != null) {
            project.save ();
        }

        return false;
    }

    public void save_current_document () {
        var document = document_manager.get_current_document ();
        if (document == null) {
            return;
        }

        document.save.begin ();
    }

    public void save_opened_documents () {
        foreach (var document in document_manager.get_opened_documents ()) {
            document.save.begin (false);
        }
    }

    public void load_project (Project? project) {
        bool valid = project != null;
        title = valid ? project.get_title () : Constants.APP_NAME;
        toolbar.show_editor_buttons = valid;

        document_manager.load_project (project);
        if (valid) {
            project.build_system.bind_property ("prebuild-command", bo_dialog.prebuild_entry, "text", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
            project.build_system.bind_property ("build-command", bo_dialog.build_entry, "text", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
            project.build_system.bind_property ("run-command", bo_dialog.run_entry, "text", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
            main_stack.visible_child_name = Constants.EDITOR_VIEW_NAME;
        } else {
            main_stack.visible_child_name = Constants.WELCOME_VIEW_NAME;
        }
    }

    public void show_open_files_dialog () {
        var dialog = new Gtk.FileChooserDialog (_("Open signle file…"), this, Gtk.FileChooserAction.OPEN,
                                                _("Cancel"),
                                                Gtk.ResponseType.CANCEL,
                                                _("Open"),
                                                Gtk.ResponseType.ACCEPT);
        dialog.select_multiple = true;
        if (dialog.run () == Gtk.ResponseType.ACCEPT) {
            foreach (unowned string uri in dialog.get_uris ()) {
                var file = File.new_for_uri (uri);
                var document = new Document (file, null);
                document_manager.add_document (document, true);
            }

            main_stack.visible_child_name = Constants.EDITOR_VIEW_NAME;
            toolbar.show_editor_buttons = true;
        }

        dialog.destroy ();
    }

    public void show_open_project_dialog () {
        var dialog = new Gtk.FileChooserDialog (_("Open project…"), this, Gtk.FileChooserAction.SELECT_FOLDER,
                                                _("Cancel"),
                                                Gtk.ResponseType.CANCEL,
                                                _("Open"),
                                                Gtk.ResponseType.ACCEPT);
        if (dialog.run () == Gtk.ResponseType.ACCEPT) {
            string root_path = dialog.get_current_folder ();
            Project.load.begin (File.new_for_path (root_path), (obj, res) => {
                var project = Project.load.end (res);
                if (project != null) {
                    load_project (project);
                }
            });
        }

        dialog.destroy ();
    }

    private void on_activated (int idx) {
        if (idx == open_file_id) {
            show_open_files_dialog ();
        } else if (idx == open_id) {
            show_open_project_dialog ();
        }
    }

    private void on_current_document_changed () {
        toolbar.save_opened_documents_menuitem.sensitive = (document_manager.get_opened_documents ().size > 0);

        bool has_current_document = document_manager.get_current_document () != null;
        toolbar.save_current_document_menuitem.sensitive = has_current_document;
        toolbar.search_button.sensitive = has_current_document;
    }

    private void on_build (bool run) {
        document_manager.build (run);
    }

    private void on_rebuild () {
        document_manager.rebuild ();
    }

    public override bool key_press_event (Gdk.EventKey event) {
        bool handled = true;
            switch (event.keyval) {
                case Gdk.Key.s:
                    if (Gdk.ModifierType.CONTROL_MASK in event.state && Gdk.ModifierType.SHIFT_MASK in event.state) {
                        save_current_document ();
                    } else if (Gdk.ModifierType.CONTROL_MASK in event.state) {
                        save_current_document ();
                    } else {
                        handled = false;
                    }
                    break;
                case Gdk.Key.F5:
                    on_build (true);
                    break;
                default:
                   handled = false;
                   break;
            }
        if (handled) {
            return true;
        }

        return (base.key_press_event != null) ? base.key_press_event (event) : true;
    }
}
