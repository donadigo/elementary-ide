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
    public class FileSearchResult {
        public string filename { get; set; }
        public Icon icon { get; set; }

        public FileSearchResult (string filename, Icon icon) {
            this.filename = filename;
            this.icon = icon;
        }
    }

    public class FileSearchEngine : Object {
        public string root_filename { get; set; }
        private Gee.ArrayList<FileSearchResult> current_array;

        private string current_query;
        private bool current_include_hidden;

        public async Gee.Collection<FileSearchResult> search_files (string query, bool include_hidden) {
            current_array = new Gee.ArrayList<FileSearchResult> ();

            current_query = query;
            current_include_hidden = include_hidden;

            var file = File.new_for_path (root_filename);
            yield process_directory (file);

            current_array.sort (path_compare_data_func);
            return current_array;
        }

        private int path_compare_data_func (FileSearchResult a, FileSearchResult b) {
            string basename_a = Path.get_basename (a.filename);
            string basename_b = Path.get_basename (b.filename);

            return strcmp (basename_a, basename_b);
        }

        private async void process_directory (File file) {
            try {
                var enumerator = yield file.enumerate_children_async ("standard::*", FileQueryInfoFlags.NONE);

                FileInfo? info;
                while ((info = enumerator.next_file ()) != null) {
                    if (info.get_name ().has_prefix (".") && !current_include_hidden) {
                        continue;
                    }

                    var subfile = enumerator.get_child (info);
                    if (info.get_file_type () == FileType.DIRECTORY) {
                        yield process_directory (subfile);
                    } else if (info.get_file_type () == FileType.REGULAR) {
                        if (info.get_content_type ().has_prefix ("text/") && info.get_display_name ().down ().contains (current_query.down ())) {
                            var result = new FileSearchResult (subfile.get_path (), info.get_icon ());
                            current_array.add (result);
                        }
                    }
                }
            } catch (Error e) {
                warning (e.message);
            }                   
        }
    }
}