namespace IDE {

    public class IDESettings : Granite.Services.Settings {
    
        private static IDESettings instance;
        
        public bool dark_theme { get; set; }
        public bool show_line_numbers { get; set; }
        
        private IDESettings () {
            base ("com.github.donadigo.elementary-ide");
        }
        
        public static IDESettings get_default () {
            if (instance == null) {
                instance = new IDESettings ();
            }
            
            return instance;
        }
    }
}


