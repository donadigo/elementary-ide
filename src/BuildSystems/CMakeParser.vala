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
        public string target { get; set; }
        
        private Gee.ArrayList<string> sources;
        private Gee.ArrayList<CMakeCommand> commands;
        private Gee.ArrayList<CMakeVariable> variables;
        private Gee.ArrayList<string> comments;

        private string prev_value;

        construct {
            // TODO: Better config

            sources = new Gee.ArrayList<string> ();
            commands = new Gee.ArrayList<CMakeCommand> ();
            comments = new Gee.ArrayList<string> ();
            variables = new Gee.ArrayList<CMakeVariable> ();
        }

        public CMakeParser (string target) {
            this.target = target;
        }

        public Gee.ArrayList<string> get_sources () {
            return sources;
        }

        public Gee.ArrayList<CMakeCommand> get_commands () {
            return commands;
        }
        
        public Gee.ArrayList<CMakeVariable> get_variables () {
            return variables;
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

            parse_file (target);
        }

        public CMakeCommand? find_command_by_name (string name) {
            foreach (var command in commands) {
                if (command.name == name) {
                    return command;
                }
            }

            return null;
        }

        public CMakeVariable? find_variable_by_name (string name) {
            foreach (var variable in variables) {
                if (variable.name == name) {
                    return variable;
                }
            }

            return null;
        }

        private void parse_file (string source) {
            string contents;

            try {
                FileUtils.get_contents (source, out contents);
            } catch (Error e) {
                warning (e.message);
                return;
            }

            var scanner = new Scanner (null);
            scanner.config.skip_comment_multi = true;
            scanner.config.skip_comment_single = false;
            scanner.config.identifier_2_string = true;
            scanner.config.scan_float = true;
            scanner.config.scan_binary = false;
            scanner.config.scan_identifier_NULL = false;
            scanner.config.scan_identifier_1char = true;
            scanner.config.scan_identifier = true;            

            string cset_identifier_nth = scanner.config.cset_identifier_nth;
            string cset_identifier_first = scanner.config.cset_identifier_first;

            scanner.config.cset_identifier_first = (string*)(cset_identifier_first + "><=+_.");
            scanner.config.cset_identifier_nth = (string*)(cset_identifier_nth + "{=-+_.\\/");

            contents = contents.compress ();
            scanner.input_text (contents, contents.length);

            CMakeCommand? current_command = null;
            bool parse_variable = false;
 
            while (!scanner.eof ()) {
                var token = scanner.get_next_token ();
                var val = scanner.cur_value ();
                switch (token) {
                    case TokenType.LEFT_PAREN:
                        current_command = new CMakeCommand (source, prev_value);
                        break;
                    case TokenType.RIGHT_PAREN:
                        commands.add (current_command);
                        if (current_command.name == Constants.SET_CMD) {
                            var arguments = current_command.get_arguments ();
                            if (arguments.length > 0) {
                                var variable = new CMakeVariable (arguments[0]);
                                for (int i = 1; i < arguments.length; i++) {
                                    variable.add_value (arguments[i]);
                                }

                                variables.add (variable);
                            }
                        } else if (current_command.name == Constants.ADD_SUBDIRECTORY_CMD) {
                            var arguments = current_command.get_arguments ();
                            if (arguments.length > 0) {
                                string next_source = Path.build_filename (Path.get_dirname (target), arguments[0], Constants.CMAKE_TARGET);
                                if (FileUtils.test (next_source, FileTest.IS_REGULAR)) {
                                    parse_file (next_source);
                                }
                            }
                        }

                        current_command = null;
                        break;
                    case TokenType.LEFT_CURLY:
                        parse_variable = true;
                        break;
                    case TokenType.STRING:
                        // TODO: check if the previous string was a dollar

                        string str = val.string;

                        if (current_command != null) {
                            if (parse_variable) {
                                var variable = find_variable_by_name (str);
                                if (variable != null) {
                                    foreach (string value in variable.get_values ()) {
                                        current_command.add_argument (value);
                                        prev_value = value;
                                    }
                                }

                                parse_variable = false;                                
                            } else {
                                current_command.add_argument (str);
                                prev_value = str;
                            }
                        } else {
                            prev_value = str;
                        }

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