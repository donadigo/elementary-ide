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
    private Gtk.Stack stack;
    private Gtk.Spinner spinner;
    private Gtk.Label error_results_label;

    construct {
        source_list = new Granite.Widgets.SourceList ();
        source_list.item_selected.connect (on_item_selected);

        error_results_label = new Gtk.Label (_("No symbols found"));
        error_results_label.justify = Gtk.Justification.CENTER;
        error_results_label.get_style_context ().add_class ("h4");
        error_results_label.wrap_mode = Pango.WrapMode.WORD_CHAR;
        error_results_label.wrap = true;

        spinner = new Gtk.Spinner ();
        spinner.start ();

        var spinner_grid = new Gtk.Grid ();
        spinner_grid.halign = spinner_grid.valign = Gtk.Align.CENTER;
        spinner_grid.add (spinner);
        spinner_grid.show_all ();
        spinner_grid.visible = true;

        stack = new Gtk.Stack ();
        stack.add_named (source_list, Constants.SYMBOL_TREE_VIEW_NAME);
        stack.add_named (spinner_grid, Constants.SYMBOL_TREE_VIEW_SPINNER_NAME);
        stack.add_named (error_results_label, Constants.SYMBOL_TREE_VIEW_ERROR_NAME);
        add (stack);
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

        stack.visible_child_name = symbols.size > 0 ? Constants.SYMBOL_TREE_VIEW_NAME : Constants.SYMBOL_TREE_VIEW_ERROR_NAME;
        expand_all ();
        spinner.stop ();
    }

    public void set_working () {
        stack.visible_child_name = Constants.SYMBOL_TREE_VIEW_SPINNER_NAME;
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
