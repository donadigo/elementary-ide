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
    public class BottomStack : Gtk.Grid {
        public Gtk.Label report_label { get; construct; }
        public Gtk.Label location_label { get; construct; }

        public TerminalWidget terminal_widget { get; construct; }
        public ReportWidget report_widget { get; construct; }

        private Gtk.Stack toolbar_stack;
        private Gtk.Stack main_stack;
        private Granite.Widgets.ModeButton mode_button;

        private int report_widget_id = -1;
        private int terminal_widget_id = -1;
        private int build_output_widget_id = -1;

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;

            report_widget = new ReportWidget ();
            report_widget.visible = true;

            terminal_widget = new TerminalWidget ();
            terminal_widget.visible = true;

            toolbar_stack = new Gtk.Stack ();
            toolbar_stack.add (report_widget.toolbar_widget);

            main_stack = new Gtk.Stack ();
            main_stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
            main_stack.add_named (report_widget, Constants.REPORT_VIEW_NAME);
            main_stack.add_named (terminal_widget, Constants.TERMINAL_VIEW_NAME);

            report_label = new Gtk.Label (null);
            location_label = new Gtk.Label (null);

            mode_button = new Granite.Widgets.ModeButton ();
            mode_button.mode_changed.connect (on_mode_changed);
            mode_button.halign = Gtk.Align.END;

            report_widget_id = mode_button.append_icon ("dialog-information-symbolic", Gtk.IconSize.MENU);
            terminal_widget_id = mode_button.append_icon ("utilities-terminal-symbolic", Gtk.IconSize.MENU);
            build_output_widget_id = mode_button.append_icon ("system-run-symbolic", Gtk.IconSize.MENU);

            var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.VERTICAL);
            size_group.add_widget (toolbar_stack);
            size_group.add_widget (mode_button);

            var toolbar_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            toolbar_box.margin = 6;
            toolbar_box.add (toolbar_stack);
            toolbar_box.add (report_label);
            toolbar_box.add (location_label);
            toolbar_box.pack_end (mode_button);

            attach (toolbar_box, 0, 0, 1, 1);
            attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 1, 1, 1);
            attach (main_stack, 0, 2, 1, 1);

            mode_button.selected = report_widget_id;
        }

        private void on_mode_changed () {
            if (mode_button.selected == report_widget_id) {
                main_stack.visible_child_name = Constants.REPORT_VIEW_NAME;
            } else if (mode_button.selected == terminal_widget_id) {
                main_stack.visible_child_name = Constants.TERMINAL_VIEW_NAME;
            }

            var selected_widget = (BottomWidget)main_stack.get_child_by_name (main_stack.visible_child_name);
            if (selected_widget.toolbar_widget != null) {
                toolbar_stack.visible_child = selected_widget.toolbar_widget;
                Utils.set_widget_visible (toolbar_stack, true);
            } else {
                Utils.set_widget_visible (toolbar_stack, false);
            }
        }        
    }
}