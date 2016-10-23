namespace IDE {
    public class InfoWindow : Gtk.Window {
        public bool pointer_in_window = false;
        private Gtk.SourceView definition_view;
        private Gtk.SourceBuffer buffer;

        construct {
            type_hint = Gdk.WindowTypeHint.TOOLTIP;
            skip_taskbar_hint = true;
            decorated = false;
            focus_on_map = true;

            var main_grid = new Gtk.Grid ();

            var frame = new Gtk.Frame (null);
            frame.add (main_grid);

            buffer = new Gtk.SourceBuffer (null);

            definition_view = new Gtk.SourceView.with_buffer (buffer);
            definition_view.expand = true;
            definition_view.editable = false;
            definition_view.show_right_margin = false;
            definition_view.cursor_visible = false;

            main_grid.add (definition_view);
            add (frame);
        }

        public bool set_content (string content) {
            definition_view.buffer.text = content;

            update_language ();
            return content.strip () != "";
        }

        public void show_at (int x, int y) {
            move (x, y);
            set_size_request (definition_view.get_allocated_width (), definition_view.get_allocated_height ());
            show_all ();
        }

        private void update_language () {
            var document = IDEWindow.get_instance ().editor_view.get_current_document ();
            if (document == null) {
                return;
            }

            buffer.set_language (document.editor_window.get_language ());       
        }
    }
}