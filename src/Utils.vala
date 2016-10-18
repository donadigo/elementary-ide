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

namespace IDE.Utils {
    public static void set_widget_visible (Gtk.Widget widget, bool visible) {
        widget.no_show_all = !visible;
        if (visible) {
            widget.show_all ();
        } else {
            widget.hide ();
        }
    }

    public static bool get_file_exists (string filename) {
        return FileUtils.test (filename, FileTest.IS_REGULAR);
    }

    public static Gtk.ResponseType show_warning_dialog (string title, string message, string icon = "warning") {
        return Gtk.ResponseType.ACCEPT;
    }

    public static void show_error_dialog (string title, string message, string icon = "error-dialog") {

    }

    public static string get_extension (File file) {
        string basename = file.get_basename ();
        int idx = basename.last_index_of (".");

        return basename.substring (idx + 1);
    }

    public static string? convert_symbol_to_definition (Vala.Symbol symbol) {
        var builder = new StringBuilder ();

        if (symbol is Vala.Namespace) {
            builder.append ("namespace ");
        } else {
            switch (symbol.access) {
                case Vala.SymbolAccessibility.PRIVATE:
                    builder.append ("private ");
                    break;
                case Vala.SymbolAccessibility.PUBLIC:
                    builder.append ("public ");
                    break;
                case Vala.SymbolAccessibility.PROTECTED:
                    builder.append ("protected ");
                    break;
                case Vala.SymbolAccessibility.INTERNAL:
                    builder.append ("internal ");
                    break;
            }
        }
            
        if (symbol is Vala.Method) {
            var method = (Vala.Method)symbol;
            if (Vala.MemberBinding.STATIC in method.binding) {
                builder.append ("static ");
            }

            builder.append (method.return_type.to_qualified_string (symbol.scope) + " ");
            builder.append (method.get_full_name () + " ");

            var params = method.get_parameters ();
            builder.append ("(");
            if (params != null && params.size > 0) {
                int index = 0;
                foreach (var param in method.get_parameters ()) {
                    if (param.ellipsis) {
                        builder.append ("...");
                    } else {
                        builder.append (param.variable_type.to_string () + " ");
                        builder.append (param.name);
                    }

                    if (index + 1 < params.size) {
                        builder.append (", ");
                    }

                    index++;
                }
            }

            builder.append (")");
        } else if (symbol is Vala.Signal) {
            var sig = (Vala.Signal)symbol;

            builder.append ("signal ");
            builder.append (sig.return_type.to_string () + " ");
            builder.append (sig.get_full_name () + " ");

            var params = sig.get_parameters ();
            builder.append ("(");
            if (params != null && params.size > 0) {
                int index = 0;
                foreach (var param in sig.get_parameters ()) {
                    if (param.ellipsis) {
                        builder.append ("...");
                    } else {
                        builder.append (param.variable_type.to_string () + " ");
                        builder.append (param.name);
                    }

                    if (index + 1 < params.size) {
                        builder.append (", ");
                    }

                    index++;
                }
            }
            
            builder.append (")");
        } else if (symbol is Vala.Delegate) {
            var delegate = (Vala.Delegate)symbol;

            builder.append (delegate.return_type.to_string () + " ");
            builder.append (delegate.get_full_name () + " ");

            var params = delegate.return_type.get_parameters ();
            builder.append ("(");
            if (params != null && params.size > 0) {
                int index = 0;
                foreach (var param in delegate.return_type.get_parameters ()) {
                    if (param.ellipsis) {
                        builder.append ("...");
                    } else {
                        builder.append (param.variable_type.to_string () + " ");
                        builder.append (param.name);
                    }

                    if (index + 1 < params.size) {
                        builder.append (", ");
                    }

                    index++;
                }
            }

            builder.append (")");
        } else if (symbol is Vala.Property) {
            var prop = (Vala.Property)symbol;
            if (Vala.MemberBinding.STATIC in prop.binding) {
                builder.append ("static ");
            }

            builder.append (prop.property_type.to_string () + " ");
            builder.append (prop.name);

            if (prop.get_accessor != null || prop.set_accessor != null) {
                builder.append (" { ");
                if (prop.get_accessor != null) {
                    builder.append ("get; ");
                }

                if (prop.set_accessor != null) {
                    builder.append ("set; ");
                }

                builder.append (" }");
            }
        } else if (symbol is Vala.Variable) {
            var variable = (Vala.Variable)symbol;
            builder.append (variable.variable_type.to_string () + " ");
            builder.append (variable.name);
        } else if (symbol is Vala.EnumValue) {
            var enum_val = (Vala.EnumValue)symbol;
            builder.append ("const int ");
            builder.append (enum_val.get_full_name ());
            if (enum_val.@value != null) {
                builder.append (" = ");
                builder.append (enum_val.value.to_string ());
            }
        } else if (symbol is Vala.Class) {
            var klass = (Vala.Class)symbol;
            if (klass.is_abstract) {
                builder.append ("abstract ");
            }

            if (klass.is_compact) {
                builder.prepend ("[Compact]\n");
            }

            builder.append ("class ");

            builder.append (klass.get_this_type ().to_string ());
            var base_types = klass.get_base_types ();
            if (base_types != null && base_types.size > 0) {
                builder.append (" : ");

                int index = 0;
                foreach (var base_type in base_types) {
                    builder.append (base_type.to_string ());
                    if (index + 1 < base_types.size) {
                        builder.append (", ");
                    }

                    index++;
                }
            }
        } else {
            builder.append (symbol.get_full_name ());
        }

        return builder.str.strip ();
    }

    public static string esc_angle_brackets (string in) {
        return in.replace ("<", "&lt;").replace (">", "&gt;");
    }    
}