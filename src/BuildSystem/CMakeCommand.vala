
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
    public class CMakeCommand : Object {
        public string filename { get; set; }
        public string name { get; set; }
        private Gee.ArrayList<string> arguments;

        construct {
            arguments = new Gee.ArrayList<string> ();
        }

        public CMakeCommand (string filename, string name) {
            this.filename = filename;
            this.name = name;
        }

        public void add_argument (string argument) {
            arguments.add (argument);
        }

        public void clear_arguments () {
            arguments.clear ();
        }

        public string[] get_arguments () {
            return arguments.to_array ();
        }
    }
}