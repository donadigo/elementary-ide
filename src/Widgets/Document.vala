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


public class Document : Granite.Widgets.Tab {
    public signal void content_changed ();

    public EditorWindow editor_window;
    public bool is_loaded { get; set; default = false; }
    private Gtk.SourceFile? source_file;
    private ThemedIcon unsaved_icon;
    private bool is_saved = false;
    private Project? project = null;

    private FileMonitor? monitor = null;
    private ulong monitor_handle_id = 0U;
    private bool saving = false;

    public bool recently_changed {
        get {
            return editor_window.source_buffer.recently_changed;
        }

        set {
            editor_window.source_buffer.recently_changed = value;
        }
    }

    public int current_line {
        get {
            return editor_window.current_line;
        }
    }

    public int current_column {
        get {
            return editor_window.current_column;
        }
    }

    construct {
        source_file = new Gtk.SourceFile ();
        unsaved_icon = new ThemedIcon ("radio-symbolic");

        editor_window = new EditorWindow (this);
        editor_window.get_buffer ().modified_changed.connect (update_saved_state);         
        editor_window.source_buffer.changed.connect (on_source_buffer_changed);
    }

    public Document (File file, Project? project) {
        source_file.set_location (file);
        this.project = project;

        init_document ();
    }

    public Document.empty () {
        init_document ();
    }

    private void init_document () {
        page = editor_window;
        update_props ();

        if (source_file.get_location () != null) {
            start_monitor ();
        }
    }

    private void update_saved_state () {
        get_is_saved.begin ((obj, res) => {
            is_saved = get_is_saved.end (res);
            icon = is_saved ? null : unsaved_icon;
        });            
    }

    private void on_source_buffer_changed () {
        if (!editor_window.source_buffer.get_modified ()) {
            return;
        }

        recently_changed = true;
        content_changed ();
        update_saved_state ();
    }

    private void update_label () {
        label = get_label ();
    }

    private void update_language () {
        string? filename = get_filename ();
        if (filename == null) {
            return;
        }

        var lang_manager = Gtk.SourceLanguageManager.get_default ();
        var lang = lang_manager.guess_language (filename, null);
        if (lang != null) {
            editor_window.set_language (lang);
        }
    }

    private void update_props () {       
        update_language ();
        update_saved_state ();
        update_label ();
    }

    private void start_monitor () {
        try {
            monitor = source_file.get_location ().monitor (FileMonitorFlags.NONE, null);
            monitor_handle_id = monitor.changed.connect ((src, dest, event) => {
                if (event == FileMonitorEvent.CHANGES_DONE_HINT && !saving) {
                    load.begin ();
                }
            });
        } catch (Error e) {
            warning (e.message);
        }
    }

    private void stop_monitor () {
        if (monitor != null && monitor_handle_id > 0ULL) {
            monitor.disconnect (monitor_handle_id);
        }
    }

    private string get_label () {
        var location = source_file.get_location ();
        if (location != null) {
            return location.get_basename ();
        }

        return _("New Document");
    }

    public string get_current_content () {
        return editor_window.source_buffer.text;
    }

    public void set_current_content (string content) {
        editor_window.source_buffer.text = content;
    }

    public void add_provider (Gtk.SourceCompletionProvider provider) {
        try {
            editor_window.source_view.completion.add_provider (provider);
        } catch (Error e) {
            warning (e.message);
        }            
    }

    public new void close () {
        stop_monitor ();
    }

    public bool get_is_vala_source () {
        var location = source_file.get_location ();
        if (location == null) {
            return false;
        }

        string ext = Utils.get_extension (location);
        return ext == "vala" || ext == "vapi";
    }

    public async bool load () {
        if (source_file.get_location () == null && !saving) {
            return false;
        }

        is_loaded = false;
        var loader = new Gtk.SourceFileLoader (editor_window.get_buffer (), source_file);

        try {
            is_loaded = yield loader.load_async (Priority.DEFAULT, null, file_progress_cb);
            update_props ();
        } catch (Error e) {
            warning (e.message);
        }

        return is_loaded;
    }

    public async bool save (bool use_save_as_fallback = true) {
        saving = true;
        if (use_save_as_fallback && !get_can_write ()) {
            return yield save_as ();
        }

        ensure_file_exists ();
        if (yield get_is_saved ()) {
            update_props ();
            return true;
        }

        is_saved = false;
        var saver = new Gtk.SourceFileSaver (editor_window.get_buffer (), source_file);

        try {
            is_saved = yield saver.save_async (Priority.DEFAULT, null, file_progress_cb);
            update_props ();
        } catch (Error e) {
            warning (e.message);
        }

        saving = false;
        return is_saved;
    }

    public async bool save_as () {
        Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
            _("Select save destination"), IDEApplication.get_main_window (), Gtk.FileChooserAction.SAVE,
            "_Cancel",
            Gtk.ResponseType.CANCEL,
            "_Save",
            Gtk.ResponseType.ACCEPT);

        chooser.select_multiple = false;

        if (chooser.run () == Gtk.ResponseType.ACCEPT) {
            string new_path = chooser.get_filename ();
            if (Utils.get_file_exists (new_path) && Utils.show_warning_dialog ("", "") == Gtk.ResponseType.ACCEPT) {

            }

            source_file.set_location (File.new_for_path (new_path));
            chooser.close ();
            return yield save ();
        }

        chooser.close ();
        return false;
    }

    public async bool get_is_saved () {
        if (source_file.get_location () == null) {
            return false;
        }

        var file_buffer = new Gtk.SourceBuffer (null);
        var source_buffer = editor_window.get_buffer ();
        var loader = new Gtk.SourceFileLoader (file_buffer, source_file);
        try {
            bool success = yield loader.load_async (Priority.DEFAULT, null, null);

            if (!success) {
                return false;
            }
        } catch (Error e) {
            warning (e.message);
            return false;
        }

        Gtk.TextIter source_start_iter;
        Gtk.TextIter source_end_iter;

        source_buffer.get_start_iter (out source_start_iter);
        source_buffer.get_end_iter (out source_end_iter);

        Gtk.TextIter file_start_iter;
        Gtk.TextIter file_end_iter;

        file_buffer.get_start_iter (out file_start_iter);
        file_buffer.get_end_iter (out file_end_iter);

        string source_text = source_buffer.get_text (source_start_iter, source_end_iter, false);
        string file_text = file_buffer.get_text (file_start_iter, file_end_iter, false);

        return source_text == file_text;
    }

    private void file_progress_cb (int64 current_num_bytes, int64 total_num_bytes) {
        editor_window.set_progress (total_num_bytes / current_num_bytes);
    }

    public string? get_filename () {
        if (source_file.get_location () == null) {
            return null;
        }

        return source_file.get_location ().get_path ();
    }

    public override void grab_focus () {
        editor_window.source_view.grab_focus ();
    }  

    public bool get_exists () {
        string? filename = get_filename ();
        if (filename == null) {
            return false;
        }

        return Utils.get_file_exists (filename);
    }

    private void ensure_file_exists () {
        if (get_exists ()) {
            return;
        }

        try {
            FileUtils.set_contents (get_filename (), "");
        } catch (Error e) {
            warning (e.message);
        }
    }

    private bool get_can_write () {
        return source_file.get_location () != null && !source_file.is_readonly ();
    }
}
