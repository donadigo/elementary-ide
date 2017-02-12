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
    public class SymbolTreeView : Gtk.Grid {
        public class SymbolItem : Granite.Widgets.SourceList.ExpandableItem {
            public Vala.Symbol symbol { get; construct; }

            construct {
                if (symbol is Vala.CreationMethod) {
                    if (symbol.name == ".new") {
                        name = ((Vala.CreationMethod)symbol).class_name;
                    } else {
                        name = "%s.%s".printf (((Vala.CreationMethod)symbol).class_name, symbol.name);
                    }
                } else {
                    name = symbol.name;
                }              

                // TODO: set an icon here
            }

            public SymbolItem (Vala.Symbol symbol) {
                Object (symbol: symbol);
            }         
        }

        public signal void symbol_selected (SymbolItem item);
        private Granite.Widgets.SourceList source_list;

        construct {
            source_list = new Granite.Widgets.SourceList ();
            source_list.item_selected.connect (on_item_selected);
            add (source_list);
        }       

        public void clear () {
            source_list.root.clear ();
        }

        public void expand_all () {
            source_list.root.expand_all ();
        }

        public void add_symbols (Gee.TreeSet<Vala.Symbol> symbols) {
            foreach (var symbol in symbols) {
                if (symbol.name == null) {
                    continue;
                }

                var match = find_existing (symbol, source_list.root);
                if (match != null) {
                    continue;
                }

                construct_child (symbol, source_list.root);
            }
        }

        private SymbolItem? find_existing (Vala.Symbol symbol, Granite.Widgets.SourceList.ExpandableItem parent) {
            foreach (var _child in parent.children) {
                var child = _child as SymbolItem;
                if (child == null) {
                    continue;
                }

                if (child.symbol == symbol) {
                    return child;
                } else {
                    var match = find_existing (symbol, child);
                    if (match != null) {
                        return match;
                    }
                }
            }

            return null;
        }

        private SymbolItem construct_child (Vala.Symbol symbol, owned Granite.Widgets.SourceList.ExpandableItem _parent) {
            Granite.Widgets.SourceList.ExpandableItem parent;
            if (symbol.scope.parent_scope == null || symbol.scope.parent_scope.owner.name == null) {
                parent = _parent;
            } else {
                parent = find_existing (symbol.scope.parent_scope.owner, _parent);
            }

            if (parent == null) {
                parent = construct_child (symbol.scope.parent_scope.owner, _parent);
            }

            var child = new SymbolItem (symbol);
            parent.add (child);
            return child;
        }

        private void on_item_selected (Granite.Widgets.SourceList.Item? item) {
            if (item == null || !(item is SymbolItem)) {
                return;
            }

            symbol_selected ((SymbolItem)item);
        }
    }
}