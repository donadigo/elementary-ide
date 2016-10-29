namespace IDE {
    public class PreferencesDialog : BaseDialog {
    
        private static PreferencesDialog instance;
        
        construct {
        
            resizable = false;

            get_content_area ().add (get_general_box ());
            
        }
        
        public static PreferencesDialog get_default () {
            if (instance == null) {
                instance = new PreferencesDialog ();
            }
            return instance;
        }
        
        private Gtk.Widget get_general_box () {
            var general_grid = new Gtk.Grid ();
            general_grid.row_spacing = 6;
            general_grid.column_spacing = 12;
            general_grid.margin = 12;
            
            var general_header = new SettingsHeader (_("General"));
            
            SettingsSwitch dark_mode_switch = new SettingsSwitch ("dark-theme");
            
            general_grid.attach (general_header, 0, 0, 2, 1);
            general_grid.attach (new SettingsLabel (_("Dark theme:")), 0, 1, 1, 1);
            general_grid.attach (dark_mode_switch, 1, 1, 1, 1);
                   
            return general_grid;
        }
        
        private class SettingsSwitch : Gtk.Switch {
            public SettingsSwitch (string setting) {
                halign = Gtk.Align.START;
                IDESettings.get_default ().schema.bind (setting, this, "active", SettingsBindFlags.DEFAULT);
            }
        }
        
        private class SettingsHeader : Gtk.Label {
            public SettingsHeader (string text) {
                label = text;
                get_style_context ().add_class ("h4");
                halign = Gtk.Align.START;
            }
        }
        
        private class SettingsLabel : Gtk.Label {
            public SettingsLabel (string text) {
                label = text;
                halign = Gtk.Align.END;
                margin_start = 12;
            }
        }
    }
}
