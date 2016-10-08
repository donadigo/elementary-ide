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
    public class CMakeParser : Object {
        private Scanner scanner;

        private Gee.ArrayList<string> sources;
        private Gee.ArrayList<CMakeCommand> commands;
        private Gee.ArrayList<string> comments;

        private string prev_value;
        private CMakeCommand? current_command;

        construct {
            // TODO: Better config
            scanner = new Scanner (null);
            scanner.config.skip_comment_multi = true;
            scanner.config.skip_comment_single = false;
            scanner.config.identifier_2_string = true;
            scanner.config.symbol_2_token = true;
            scanner.config.scan_float = true;
            scanner.config.scan_binary = false;
            scanner.config.scan_identifier_NULL = false;
            scanner.config.scan_identifier_1char = true;
            scanner.config.scan_identifier = true;            

            string cset_identifier_nth = scanner.config.cset_identifier_nth;
            scanner.config.cset_identifier_nth = (string*)(cset_identifier_nth + "=-_.\\/");

            sources = new Gee.ArrayList<string> ();
            commands = new Gee.ArrayList<CMakeCommand> ();
            comments = new Gee.ArrayList<string> ();
        }

        public Gee.ArrayList<string> get_sources () {
            return sources;
        }

        public Gee.ArrayList<CMakeCommand> get_commands () {
            return commands;
        }

        public Gee.ArrayList<string> get_comments () {
            return comments;
        }

        public void add_cmake_source (string source) {
            sources.add (source);
        }   

        public void remove_cmake_source (string source) {
            sources.remove (source);
        }

        public void parse () {
            commands.clear ();
            comments.clear ();

            foreach (string source in sources) {
                parse_file (source);       
            }
        }

        private void parse_file (string source) {
            string contents;

            try {
                FileUtils.get_contents (source, out contents);
            } catch (Error e) {
                warning (e.message);
                return;
            }

            contents = contents.compress ();
            scanner.input_text (contents, contents.length);

            // TODO: variables
            while (!scanner.eof ()) {
                var token = scanner.get_next_token ();
                var val = scanner.cur_value ();
                switch (token) {
                    case TokenType.LEFT_PAREN:
                        current_command = new CMakeCommand (prev_value);
                        break;
                    case TokenType.RIGHT_PAREN:
                        commands.add (current_command);
                        current_command = null;
                        break;
                    case TokenType.STRING:
                        string str = val.string;
                        if (current_command != null) {
                            current_command.add_argument (str);
                        }

                        prev_value = str;
                        break;
                    case TokenType.FLOAT:
                        string str = val.float.to_string ();
                        if (current_command != null) {
                            current_command.add_argument (str);
                        }

                        prev_value = str;
                        break;
                    case TokenType.COMMENT_SINGLE:
                        comments.add (val.comment);
                        break;
                    case TokenType.INT:
                        string str = val.int.to_string ();
                        if (current_command != null) {
                            current_command.add_argument (str);
                        }

                        prev_value = str;
                        break;
                    default:
                        break;
                }
            }
        }   
    }
}