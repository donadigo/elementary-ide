/*
 * Copyright (C) 2008 Abderrahim Kitouni
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace IDE {
	/* Finds the innermost block containing the given location */
	public class BlockLocator : Vala.SymbolResolver {
		public struct Location {
			int line;
			int column;
			public Location (int line, int column) {
				this.line = line;
				this.column = column;
			}

			public bool inside (Vala.SourceReference src) {
				var begin = Location (src.begin.line, src.begin.column);
				var end = Location (src.end.line, src.end.column);
				return begin.before (this) && this.before(end);
			}
			
			public bool before (Location other) {
				if (line > other.line)
					return false;
				if (line == other.line && column > other.column)
					return false;
				return true;
			}
		}

		Location location;
		Vala.Symbol innermost;
		Location innermost_begin;
		Location innermost_end;
		string filename;
		Vala.SourceFile file;

		public Vala.Symbol? locate (Vala.SourceFile file, int line, int column) {
			this.filename = file.filename;
			this.file = file;
			location = Location (line, column);
			innermost = null;
			file.accept_children (this);
			return innermost;
		}

		bool update_location (Vala.Symbol symbol) {
			if (symbol == null ||
				symbol.source_reference == null ||
				symbol.source_reference.file.filename != filename ||
				!location.inside (symbol.source_reference)) {
				return false;
			}

			var begin = Location (symbol.source_reference.begin.line, symbol.source_reference.begin.column);
			var end = Location (symbol.source_reference.end.line, symbol.source_reference.end.column);

			if (innermost == null || innermost_begin.before (begin) && end.before (innermost_end)) {
				innermost = symbol;
				innermost_begin = begin;
				innermost_end = end;
				return true;
			}

			return false;
		}

		private bool update_expression_location (Vala.Expression expr) {
			if (expr == null ||
				expr.source_reference == null ||
				expr.source_reference.file.filename != filename ||
				!location.inside (expr.source_reference)) {
				return false;
			}

			var begin = Location (expr.source_reference.begin.line, expr.source_reference.begin.column);
			var end = Location (expr.source_reference.end.line, expr.source_reference.end.column);

			if (innermost == null || innermost_begin.before (begin) && end.before (innermost_end)) {
				innermost = expr.symbol_reference;
				innermost_begin = begin;
				innermost_end = end;
				return true;
			}

			return false;
		}

		public override void visit_local_variable (Vala.LocalVariable l) {
			update_location (l);
			l.accept_children (this);
		}

		public override void visit_block (Vala.Block b) {
			update_location (b);
			b.accept_children (this);
		}

		public override void visit_namespace (Vala.Namespace ns) {
			update_location (ns);
			ns.accept_children (this);
		}
		public override void visit_class (Vala.Class cl) {
			update_location (cl);
			cl.accept_children (this);
		}

		public override void visit_struct (Vala.Struct st) {
			update_location (st);
			st.accept_children(this);
		}
		public override void visit_interface (Vala.Interface iface) {
			update_location (iface);
			iface.accept_children (this);
		}

		public override void visit_method (Vala.Method m) {
			update_location (m);
			foreach (var param in m.get_parameters ()) {
				if (update_location (param)) {
					param.accept_children (this);
				}
			}
			
			m.accept_children (this);
		}

		public override void visit_formal_parameter (Vala.Parameter p) {
			update_location (p);
			p.accept_children (this);
		}

		public override void visit_creation_method (Vala.CreationMethod m) {
			update_location (m);
			m.accept_children (this);
		}

		public override void visit_property (Vala.Property prop) {
			update_location (prop);
			prop.accept_children (this);
		}

		public override void visit_property_accessor (Vala.PropertyAccessor acc) {
			acc.accept_children(this);
		}
		public override void visit_constructor (Vala.Constructor c) {
			update_location (c);
			c.accept_children (this);
		}
		public override void visit_destructor (Vala.Destructor d) {
			update_location (d);
			d.accept_children (this);
		}
		public override void visit_if_statement (Vala.IfStatement stmt) {
			stmt.accept_children (this);
		}
		public override void visit_switch_statement (Vala.SwitchStatement stmt) {
			stmt.accept_children (this);
		}
		public override void visit_switch_section (Vala.SwitchSection section) {
			visit_block (section);
		}

		public override void visit_constant (Vala.Constant constant) {
			update_location (constant);
			constant.accept_children (this);
		}

		public override void visit_enum (Vala.Enum enum) {
			update_location (enum);
			enum.accept_children (this);
		}

		public override void visit_enum_value (Vala.EnumValue val) {
			update_location (val);
			val.accept_children (this);
		}

		public override void visit_while_statement (Vala.WhileStatement stmt) {
			stmt.accept_children (this);
		}
		public override void visit_do_statement (Vala.DoStatement stmt) {
			stmt.accept_children (this);
		}
		public override void visit_for_statement (Vala.ForStatement stmt) {
			stmt.accept_children (this);
		}
		public override void visit_foreach_statement (Vala.ForeachStatement stmt) {
			stmt.accept_children (this);
		}
		public override void visit_try_statement (Vala.TryStatement stmt) {
			stmt.accept_children (this);
		}
		public override void visit_catch_clause (Vala.CatchClause clause) {
			clause.accept_children (this);
		}
		public override void visit_lock_statement (Vala.LockStatement stmt) {
			stmt.accept_children (this);
		}
		// add these functions.
		public override void visit_lambda_expression (Vala.LambdaExpression expr) {
			update_expression_location (expr);
		}

		public override void visit_expression_statement (Vala.ExpressionStatement stmt) {
			stmt.accept_children (this);
		}

		public override void visit_delegate (Vala.Delegate delegate) {
			update_location (delegate);
			delegate.accept_children (this);
		}

		public override void visit_end_full_expression (Vala.Expression expr) {
 			if (expr is Vala.LambdaExpression)
 				visit_method ((expr as Vala.LambdaExpression).method);
 			if (expr is Vala.MethodCall) {
 				foreach (Vala.Expression e in (expr as Vala.MethodCall).get_argument_list ()) {
 					visit_expression (e);
 				}
 			}
 		}

		public override void visit_expression (Vala.Expression expr) {
			update_expression_location (expr);
			expr.accept_children (this);
		}

		public override void visit_method_call (Vala.MethodCall mc) {
			visit_expression (mc);
		}

		public override void visit_signal (Vala.Signal sig) {
			update_location (sig);
			sig.accept_children (this);
		}
	}
}