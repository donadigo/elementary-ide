namespace IDE {

    public class IDESettings : Granite.Services.Settings {
        
        public bool dark_theme { get; set; }
        public bool show_line_numbers { get; set; }
        
        public IDESettings () {
            base ("com.github.donadigo.elementary-ide");
            }
        
    }
    
}


