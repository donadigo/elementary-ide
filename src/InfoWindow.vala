namespace IDE {
    public class InfoWindow : Gtk.Window {
        private Gtk.Label tooltip_label;

        construct {
            type = Gtk.WindowType.POPUP;
            type_hint = Gdk.WindowTypeHint.TOOLTIP;
            skip_taskbar_hint = true;
            decorated = false;
            focus_on_map = true;
            resizable = false;

            get_style_context ().add_class (Gtk.STYLE_CLASS_TOOLTIP);
            set_accessible_role (Atk.Role.TOOL_TIP);

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            tooltip_label = new Gtk.Label (null);
            tooltip_label.max_width_chars = 120;
            tooltip_label.wrap = true;
            tooltip_label.margin = 6;
            box.add (tooltip_label);
            add (box);
        }

        public void set_label (string label) {
            tooltip_label.label = label;
        }

        public void show_at (int x, int y) {
            move (x, y);
            show_all ();
        }
    }
}