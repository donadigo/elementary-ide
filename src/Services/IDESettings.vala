namespace IDE {

    public class IDESettings : Granite.Services.Settings {
        private static IDESettings instance;
        public static unowned IDESettings get_default () {
            if (instance == null) {
                instance = new IDESettings ();
            }
            
            return instance;
        }

        public bool dark_theme { get; set; }
        public bool show_line_numbers { get; set; }
        public bool highlight_current_line { get; set; }
        public bool highlight_syntax { get; set; }
        public bool highlight_matching_brackets { get; set; }
        public string font_desc { get; set; }
        
        private IDESettings () {
            base ("com.github.donadigo.elementary-ide");
        }
    }
}


