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
	public class NewFileDialog : BaseDialog {
		private const string CLASS_ID = "class";
		private const string INTERFACE_ID = "interface";

		private Gtk.Button create_button;

		private Gtk.ComboBoxText type_combo;

		private Gtk.Entry package_name_entry;
		private Gtk.Entry name_entry;
		private Gtk.Entry inherits_entry;

		private Gtk.Label abstract_label;
		private Gtk.Switch abstract_switch;
		private Gtk.Label mod_label;

		construct {
			resizable = false;

			create_button = new Gtk.Button.with_label (_("Create"));
			create_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
			create_button.clicked.connect (on_create_button_clicked);

			var action_area = (Gtk.Box)get_action_area ();
			action_area.pack_end (create_button);

			var main_grid = new Gtk.Grid ();
			main_grid.margin = 12;
			main_grid.row_spacing = 12;
			main_grid.column_spacing = 6;
            get_content_area ().add (main_grid);

	        var title_label = new Gtk.Label (_("General"));
	        title_label.xalign = 0;
	        title_label.hexpand = true;
	        title_label.get_style_context ().add_class ("h4");
	        main_grid.attach (title_label, 0, 0, 1, 1);

	        var type_label = new Gtk.Label (_("Type:"));
	        type_label.halign = Gtk.Align.END;

	        package_name_entry = new Gtk.Entry ();
	        package_name_entry.placeholder_text = _("Example.vala");

	        var package_name_label = new Gtk.Label (_("Package name:"));

            main_grid.attach (package_name_label, 0, 1, 1, 1);
            main_grid.attach (package_name_entry, 1, 1, 1, 1);	        

	        type_combo = new Gtk.ComboBoxText ();
	        type_combo.append (CLASS_ID, _("Class"));
	        type_combo.append (INTERFACE_ID, _("Interface"));
	        type_combo.active_id = CLASS_ID;
	        type_combo.changed.connect (on_type_combo_changed);

	        main_grid.attach (type_label, 0, 2, 1, 1);
	        main_grid.attach (type_combo, 1, 2, 1, 1);

            name_entry = new Gtk.Entry ();
            name_entry.hexpand = true;

            var name_label = new Gtk.Label (_("Name:"));
            name_label.halign = Gtk.Align.END;

            main_grid.attach (name_label, 0, 3, 1, 1);
            main_grid.attach (name_entry, 1, 3, 1, 1);

            inherits_entry = new Gtk.Entry ();
            inherits_entry.hexpand = true;

            var inherits_label = new Gtk.Label (_("Inherits:"));
            inherits_label.halign = Gtk.Align.END;

            main_grid.attach (inherits_label, 0, 4, 1, 1);
            main_grid.attach (inherits_entry, 1, 4, 1, 1);

	        mod_label = new Gtk.Label (_("Modifiers"));
	        mod_label.xalign = 0;
	        mod_label.hexpand = true;
	        mod_label.get_style_context ().add_class ("h4");
	        main_grid.attach (mod_label, 0, 5, 1, 1);

	        abstract_switch = new Gtk.Switch ();

	        abstract_label = new Gtk.Label (_("Abstract:"));
	        abstract_label.halign = Gtk.Align.END;

	        var switch_box = new Gtk.Grid ();
	        switch_box.add (abstract_switch);

	        main_grid.attach (abstract_label, 0, 6, 1, 1);
	        main_grid.attach (switch_box, 1, 6, 1, 1);
		}

		private void on_type_combo_changed () {
			bool sensitive = type_combo.get_active_id () == CLASS_ID;
			abstract_label.sensitive = sensitive;
			abstract_switch.sensitive = sensitive;
		}

		private void on_create_button_clicked () {
			var file = File.new_for_path ("/tmp/%s".printf (package_name_entry.get_text ()));
			try {
				if (!file.query_exists ()) {
					file.create (FileCreateFlags.NONE);
				}

				FileUtils.set_contents (file.get_path (), generate_current_template ());
			} catch (Error e) {
				warning (e.message);
			}

			var document_manager = IDEWindow.get_default ().document_manager;
			var document = new Document (file, null);
			document_manager.add_document (document, true);

			hide ();
		}

		private string generate_current_template () {
			// TODO: use Vala.CodeWriter

			int ident = 4;
			string ident_str = string.nfill (ident, ' ');
			bool is_class = type_combo.get_active_id () == CLASS_ID;

			bool inherits = inherits_entry.get_text () != "";

			var builder = new StringBuilder ("public ");
			if (abstract_switch.get_active () && !is_class) {
				builder.append ("abstract ");
			}

			builder.append ("%s %s ".printf (type_combo.get_active_id (), name_entry.get_text ()));

			if (inherits) {
				builder.append (": %s ".printf (inherits_entry.get_text ()));
			}

			builder.append ("{\n");

			if (is_class) {
				builder.append (ident_str);
				builder.append ("public %s () {\n".printf (name_entry.get_text ()));
				builder.append (ident_str);
				builder.append ("\n" + ident_str + "}");
			}

			builder.append ("\n}");
			return builder.str;
		}
	}
}
