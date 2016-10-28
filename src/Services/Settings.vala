namespace IDE {

    public class Settings : Granite.Services.Settings {
        
        public bool dark_theme { get; set; }
        public bool show_line_numbers { get; set; }
        
        public Settings () {
            base ("org.ide");
            }
        
    }
    
}


