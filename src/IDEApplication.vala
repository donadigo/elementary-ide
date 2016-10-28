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
    public class IDEApplication : Granite.Application {
        construct {
            program_name = Constants.APP_NAME;
            exec_name = Constants.EXEC_NAME;

            /*build_data_dir = Constants.DATADIR;
            build_pkg_data_dir = Constants.PKGDATADIR;
            build_release_name = Constants.RELEASE_NAME;
            build_version = Constants.VERSION;
            build_version_info = Constants.VERSION_INFO;*/

            Intl.setlocale (LocaleCategory.ALL, "");

            app_years = "2011-2016";
            app_icon = "applications-development";
            app_launcher = "elementary-ide.desktop";
            application_id = "org.donadigo.elementary-ide";

            main_url = "https://code.launchpad.net/elementary-ide";
            bug_url = "https://bugs.launchpad.net/elementary-ide";
            help_url = "https://elementary.io/help/elementary-ide";
            translate_url = "https://translations.launchpad.net/elementary-ide";

            about_authors = { "Adam Bieńkowski <donadigos159@gmail.com>" };
            about_translators = _("about-translators");
            about_license_type = Gtk.License.GPL_3_0;

            flags |= GLib.ApplicationFlags.HANDLES_OPEN;
        }

        private static IDEApplication? instance = null;
        public new static unowned IDEApplication get_default () {
            if (instance == null) {
                instance = new IDEApplication ();
            }

            return instance;
        }

        public override void open (File[] files, string hint) {

        }

        public override void activate () {
            var window = IDEWindow.get_default ();
            window.set_application (this);
            window.show_all ();
        }
    }

    public static int main (string[] args) {
        return IDEApplication.get_default ().run (args);
    }
}