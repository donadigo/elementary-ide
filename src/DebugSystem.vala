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
    public class DebugSystem : Object {
        public class EnvironmentVariable {
            public string name { get; set; }
            public string value { get; set; }

            public EnvironmentVariable (string name, string value) {
                this.name = name;
                this.value = value;
            }
        }

        public class Template : Object {
            public string name { get; set; }
            public Gee.ArrayList<EnvironmentVariable> environment_variables { public get; construct; }
            public Gee.ArrayList<string> run_arguments { public get; construct; }

            construct {
                environment_variables = new Gee.ArrayList<EnvironmentVariable> ();
                run_arguments = new Gee.ArrayList<string> ();
            }

            public Template (string name) {
                this.name = name;
            }
        }

        public Gee.ArrayList<Template> templates { public get; construct; }

        construct {
            templates = new Gee.ArrayList<Template> ();
        }
    }
}