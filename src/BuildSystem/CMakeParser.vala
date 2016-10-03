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
	public enum TokenType {
		LEFT_PARENTHESIS,
		RIGHT_PARENTHESIS,
		STRING,
		WORD,
		NEWLINE
	}

	public struct CMakeArgument {
		string name;
		Value value;
	}

	public struct CMakeCommand {
		string name;
		CMakeArgument[] arguments;
	}

	public class CMakeParser : Object {
		public List<CMakeCommand?> commands;
		private List<string> source_list;
		//private Regex command_regex;

		construct {
			commands = new List<CMakeCommand?> ();
			source_list = new List<string> ();
			//command_regex = new Regex ("/^\s*(?P<name>.*)\s*(\s*(?P<parameters>.*)\s*)/");
		}

		public void add_source (string source) {
			source_list.append (source);
		}

		public void remove_source (string source) {
			unowned List<string> _source = source_list.find_custom (source, strcmp);
			source_list.remove_link (_source);
		}

		public void parse () {
			foreach (string source in source_list) {
				parse_source (source);
			}
		}

		private void parse_source (string source) {
			string buffer;
			try {
				FileUtils.get_contents (source, out buffer);
			} catch (Error e) {
				warning (e.message);
			}

		}
	}
}