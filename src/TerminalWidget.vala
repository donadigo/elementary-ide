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
	public class TerminalWidget : Gtk.Box, BottomWidget {
        public Gtk.Widget? toolbar_widget {
            get {
                return null;
            }
        }

        private Gtk.Grid toolbar_grid;

		private Vte.Terminal terminal;
		private Vte.Pty pty;

		construct {
			terminal = new Vte.Terminal ();
			terminal.expand = true;

			try {
				pty = new Vte.Pty.sync (Vte.PtyFlags.DEFAULT);
				terminal.set_pty (pty);
			} catch (Error e) {
				warning (e.message);
			}

			toolbar_grid = new Gtk.Grid ();

			add (terminal);
		}

		public Vte.Terminal get_terminal () {
			return terminal;
		}

		public void spawn_default (string? working_directory = null) {
			string[] argv = { Environment.get_variable ("SHELL") };
			spawn_command (argv, working_directory);
		}

		public void spawn_command (string[] argv, string? working_directory = null) {
			string[] _argv = {};
			foreach (string arg in argv) {
				_argv += arg;
			}

			string[] envv = Environ.get ();

			Idle.add (() => {
				try {
					Pid child_pid;
					terminal.spawn_sync (Vte.PtyFlags.DEFAULT, working_directory, _argv,
                                	envv, SpawnFlags.SEARCH_PATH, null, out child_pid, null);	
				} catch (Error e) {
					warning (e.message);
				}
				
				return false;
			});
		}
	}
}