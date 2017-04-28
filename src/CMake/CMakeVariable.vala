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

public class CMakeVariable : Object {
    public string name { get; set; }
    private Gee.ArrayList<string> values;

    construct {
        values = new Gee.ArrayList<string> ();
    }

    public CMakeVariable (string name) {
        this.name = name;
    }

    public void add_value (string value) {
        values.add (value);
    }

    public string get_first_value () {
        if (values.size <= 0) {
            return "";
        }

        return values[0];
    }

    public string[] get_values () {
        return values.to_array ();
    }       
}
