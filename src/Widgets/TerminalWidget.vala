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

public class TerminalWidget : Gtk.Box, BottomWidget {
    public Gtk.Widget? toolbar_widget {
        get {
            return null;
        }
    }

    public Terminal terminal { get; construct; }
    public Vte.Pty pty { get; construct; }

    private Gtk.Grid toolbar_grid;

    construct {
        terminal = new Terminal ();
        terminal.expand = true;

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (terminal);

        try {
            pty = new Vte.Pty.sync (Vte.PtyFlags.DEFAULT);
            terminal.set_pty (pty);
        } catch (Error e) {
            warning (e.message);
        }

        toolbar_grid = new Gtk.Grid ();

        add (scrolled);
    }

    public void clear () {
        terminal.reset (true, true);
    }

    public void spawn_default (string? working_directory = null) {
        string[] argv = { Utils.get_default_shell () };
        Idle.add (() => {
            spawn_command (argv, working_directory);
            return false;
        });
    }

    public void spawn_command (string[] argv, string? working_directory = null) {
        string[] _argv = {};
        foreach (string arg in argv) {
            _argv += arg;
        }

        _argv += null;

        try {
            terminal.spawn_sync (Vte.PtyFlags.DEFAULT, working_directory, _argv,
                            Environ.get (), SpawnFlags.SEARCH_PATH, null, null, null);
        } catch (Error e) {
            warning (e.message);
        }
    }
}
