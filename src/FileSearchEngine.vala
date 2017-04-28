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
 
public class SearchLocation {
    public Location location { get; set; }
    public int column_end { get; set; }
    public string line { get; set; }

    public SearchLocation (Location location, int column_end, string line) {
        this.location = location;
        this.column_end = column_end;
        this.line = line;
    }
}

public class FileSearchResult {
    public string filename { get; set; }
    public Icon icon { get; set; }
    public SearchLocation? search_location { get; set; }
    public int column_end { get; set; }

    public FileSearchResult (string filename, Icon icon, SearchLocation? search_location) {
        this.filename = filename;
        this.icon = icon;
        this.search_location = search_location;
        this.column_end = column_end;
    }
}

public class FileSearchEngine : Object {
    public string root_filename { get; set; }

    public async Gee.Collection<FileSearchResult> search_files (string query, bool search_content, Cancellable? cancellable) {
        var array = new Gee.ArrayList<FileSearchResult> ();

        var file = File.new_for_path (root_filename);
        yield process_directory (array, file, query, search_content, cancellable);

        if (cancellable != null && cancellable.is_cancelled ()) {
            array.clear ();
        } else {
            array.sort (path_compare_data_func);
        }

        return array;
    }

    private int path_compare_data_func (FileSearchResult a, FileSearchResult b) {
        string basename_a = Path.get_basename (a.filename);
        string basename_b = Path.get_basename (b.filename);

        return strcmp (basename_a, basename_b);
    }

    private async void process_directory (Gee.ArrayList<FileSearchResult> array,
                                        File file,
                                        string query,
                                        bool search_content,
                                        Cancellable? cancellable) {
        if (cancellable != null && cancellable.is_cancelled ()) {
            return;
        }

        try {
            var enumerator = yield file.enumerate_children_async ("standard::*", FileQueryInfoFlags.NONE);

            FileInfo? info;
            while ((info = enumerator.next_file (cancellable)) != null) {
                if (info.get_name ().has_prefix (".")) {
                    continue;
                }

                var subfile = enumerator.get_child (info);
                if (info.get_file_type () == FileType.DIRECTORY) {
                    yield process_directory (array, subfile, query, search_content, cancellable);
                } else if (info.get_file_type () == FileType.REGULAR) {
                    if (search_content) {                        
                        uint8[] buffer;
                        yield subfile.load_contents_async (null, out buffer, null);
                        foreach (var location in search_contents ((string)buffer, query)) {
                            var result = new FileSearchResult (subfile.get_path (), info.get_icon (), location);
                            array.add (result);
                        }
                    } else if (info.get_content_type ().has_prefix ("text/") && info.get_display_name ().down ().contains (query.down ())) {
                        var result = new FileSearchResult (subfile.get_path (), info.get_icon (), null);
                        array.add (result);
                    }
                }
            }
        } catch (Error e) {
            warning (e.message);
        }                   
    }

    private Gee.ArrayList<SearchLocation> search_contents (string contents, string query) {
        var location_array = new Gee.ArrayList<SearchLocation> ();

        int line_index = 1;
        foreach (string line in contents.split ("\n")) {
            int index = 0;
            do {
                line = line.strip ();
                index = line.down ().index_of (query.down (), index);
                if (index >= 0) {
                    var location = new Location (line_index, 0);
                    var search_location = new SearchLocation (location, index + query.length, line);
                    location_array.add (search_location);
                }
            } while (index++ >= 0);

            line_index++;
        }

        return location_array;
    }
}
