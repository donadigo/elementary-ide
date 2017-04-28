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
    public bool draw_spaces_tabs { get; set; }
    public string font_desc { get; set; }
    
    private IDESettings () {
        base ("com.github.donadigo.elementary-ide");
    }
}

