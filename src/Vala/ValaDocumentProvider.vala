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
    public class ValaDocumentProvider : Object, Gtk.SourceCompletionProvider {
        public class SymbolItem : GLib.Object, Gtk.SourceCompletionProposal {
            public Vala.Symbol symbol { get; construct; }
            public string info { get; set; default = ""; }

            public SymbolItem (Vala.Symbol symbol) {
                GLib.Object (symbol: symbol);

                info = Utils.convert_symbol_to_definition (symbol);
            }
                
            public unowned GLib.Icon? get_gicon () {
                return null;
            }

            public unowned string? get_icon_name () { return null; }
            public string? get_info () { return info; }
            public string get_label () { return symbol.name; }
            public string get_markup () { return symbol.name; }
            public string get_text () { return symbol.name; }
        }

        private DocumentManager manager { get; private set; }

        private Regex member_access;
        private Regex member_access_split;
        
        private Gtk.Grid info_widget;
        private Gtk.Label definition_label;
        private Gtk.Label comment_label;

        construct {
            try {
                member_access = new Regex ("""((?:\w+(?:\s*\([^()]*\))?\.)*)(\w*)$""");
                member_access_split = new Regex ("""(\s*\([^()]*\))?\.""");
            } catch (RegexError e) {
                warning (e.message);
            }

            definition_label = new Gtk.Label (null);
            definition_label.use_markup = true;

            comment_label = new Gtk.Label (null);

            info_widget = new Gtk.Grid ();
            info_widget.attach (definition_label, 0, 0, 1, 1);
            info_widget.attach (comment_label, 0, 1, 1, 1);
            info_widget.show_all ();
        }

    	public ValaDocumentProvider (DocumentManager manager) {
            this.manager = manager;
    	}

        public string get_name () {
            return _("Vala Completion");
        }

        public bool match (Gtk.SourceCompletionContext context) {
            return true;
        }   

        public void populate (Gtk.SourceCompletionContext context) {
            var document = manager.get_current_document ();
            if (document == null) {
                return;
            }

            Gtk.TextIter iter;
            Gtk.TextIter begin = Gtk.TextIter ();

            if (!context.get_iter (out iter)) {
                context.add_proposals (this, null, true);
                return;
            }
            
            begin.assign (iter);
            begin.set_line_offset (0);

            var list = new List<Gtk.SourceCompletionProposal> ();
            var cancellable = new GLib.Cancellable ();
            context.cancelled.connect (() => {
                cancellable.cancel ();
            });

            var index = (ValaCodeParser)manager.get_code_parser ();
            if (index == null) {
                context.add_proposals (this, null, true);
                return;
            }

            string? line = begin.get_slice (iter);
            if (line == null) {
                context.add_proposals (this, null, true);
                return;
            }

            MatchInfo match_info;
            if (!member_access.match (line, 0, out match_info)) {
                context.add_proposals (this, null, true);
                return;
            }

            if (match_info.fetch (0).length < 1) {
                context.add_proposals (this, null, true);
                return;
            }

            string prefix = match_info.fetch (2);
            string[] names = member_access_split.split (match_info.fetch (1));

            var symbols = index.lookup_visible_symbols_at (document.get_file_path (), document.current_line + 1, document.current_column);
            foreach (var symbol in symbols) {
                if (symbol != null && symbol.name.has_prefix (prefix)) {
                    list.append (new SymbolItem (symbol));
                }
            }

            string[] ns = new string[0];
            foreach (var name in names) {
                if (name[0] != '(') {
                    ns += name;
                }
            }

            names = new string[0];
            foreach (var name in ns) {
                names += name;
            }

            if (names.length > 0) {
                names[names.length - 1] = prefix;
                list = new List<Gtk.SourceCompletionProposal>();
                foreach (var symbol in symbols) {
                    if (symbol != null && symbol.name == names[0]) {
                        list.append (new SymbolItem (symbol));
                    }
                }

                for (var i = 1; i < names.length; i++) {
                    Vala.Symbol? current = null;
                    list.foreach (prop => {
                        if (current != null) {
                            return;
                        }

                        var sym = (prop as SymbolItem).symbol;
                        if (sym.name == names[i - 1]) {
                            current = sym;
                        }
                    });

                    if (current == null) {
                        break;
                    }

                    list = new List<Gtk.SourceCompletionProposal> ();
                    index.get_symbols_for_name (current, names[i], false).foreach (sym => {
                        list.append (new SymbolItem (sym));
                        return true;
                    });
                }
            }                

            list.sort ((a, b) => {
                var sym_a = ((SymbolItem)a).symbol;
                var sym_b = ((SymbolItem)b).symbol;
                return strcmp (sym_a.name, sym_b.name);
            });

            if (!cancellable.is_cancelled ()) {
                context.add_proposals (this, list, true);
            }
        }    

        public unowned Gtk.Widget? get_info_widget (Gtk.SourceCompletionProposal proposal) {
            var symbol_item = (SymbolItem)proposal;
            definition_label.label = "<b>" + Markup.escape_text (symbol_item.info) + "</b>";

            var comment = symbol_item.symbol.comment;
            comment_label.visible = comment != null;
            if (comment != null) {
                comment_label.label = null;
            }

            return info_widget;
        }

        public void update_info (Gtk.SourceCompletionProposal proposal, Gtk.SourceCompletionInfo info) {
            // info.set_widget (null);
        }

        public int get_priority () {
            return 1;
        }

        public Gtk.SourceCompletionActivation get_activation () {
            return Gtk.SourceCompletionActivation.INTERACTIVE | Gtk.SourceCompletionActivation.USER_REQUESTED;
        }            
    }
}