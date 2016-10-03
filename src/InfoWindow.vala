namespace IDE {
	public class InfoWindow : Gtk.Window {
		private Gtk.Label definition_label;

		construct {
			type_hint = Gdk.WindowTypeHint.TOOLTIP;
			decorated = false;

			var main_grid = new Gtk.Grid ();
			main_grid.margin = 6;

			definition_label = new Gtk.Label (null);
			definition_label.halign = Gtk.Align.START;
			definition_label.wrap_mode = Pango.WrapMode.WORD_CHAR;
			main_grid.add (definition_label);			
			add (main_grid);
		}

		public void set_current_symbol (Vala.Symbol symbol) {
			var item = new ValaDocumentProvider.SymbolItem (symbol);
			definition_label.label = item.info;
		}

		public void show_at (int x, int y) {
			move (x, y);
			show_all ();
		}
	}
}