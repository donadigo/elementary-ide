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

public class BuildSystem : Object {
    public string clean_command { get; set; default = ""; }
    public string prebuild_command { get; set; default = ""; }
    public string build_command { get; set; default = ""; }
    public string install_command { get; set; default = ""; }
    public string run_command { get; set; default = ""; }

    public void clean () throws Error {

    }

    public void build () throws Error {

    }

    public void install () throws Error {
        
    }

    public void run () throws Error {

    }
}
