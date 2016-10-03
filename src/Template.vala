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
	public abstract class Template : Object {
		private static uint id_count;
		private static List<Template> registered;
		public static List<Template> get_registered () {
			return registered.copy ();
		}

		public static Template? get_from_id (uint id) {
			foreach (var template in registered) {
				if (template.id == id) {
					return template;
				}
			}

			return null;
		}

		public static void register (Template template) {
			registered.append (template);
		}

		static construct {
			registered = new List<Template> ();
			id_count = 0;
		}

		construct {
			properties_table = new HashTable<string, string> (null, null);
			id = id_count++;
		}

		public int cursor_line { get; set; }
		public int cursor_column { get; set; }
		public uint id { get; construct; }

		public string display_name { get; set; }
		public HashTable<string, string> properties_table { get; set; }

		public abstract string get_formated_string ();
	}
}