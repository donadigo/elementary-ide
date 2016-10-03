namespace IDE {

	public class ValaDocumentation : Object {
		public static Valadoc.Settings settings;
		private static Valadoc.ErrorReporter reporter;

		static construct {

		}

		public static void run () {
			settings = new Valadoc.Settings ();
			settings.gir_directory = ".";
			settings.with_deps = true;
			settings.packages = { "granite" };

			reporter = new Valadoc.ErrorReporter ();
			reporter.settings = settings;

/*			var module_loader = Valadoc.ModuleLoader.get_instance ();
			string pluginpath = Valadoc.ModuleLoader.get_driver_path (null, reporter);
			var driver = module_loader.create_driver (pluginpath);

			var doctree = driver.build (settings, reporter);*/

			var tree = new Valadoc.Api.Tree (reporter, settings);
			var parser = new Valadoc.DocumentationParser (settings, reporter, tree, Valadoc.ModuleLoader.get_instance ());
			var gir = new Valadoc.Importer.GirDocumentationImporter (tree, parser, Valadoc.ModuleLoader.get_instance (), settings, reporter);

			Valadoc.Importer.DocumentationImporter[] importers = {
				gir
			};

			string[] packages = { "Granite-1.0" };
			string[] imp = { "/usr/share/gir-1.0" };
			tree.import_comments (importers, packages, imp);
			tree.check_comments (parser);

			Visitor registrar = new Visitor ();
			tree.accept (registrar);

			print (tree.search_symbol_str (null, "Granite.app").get_full_name () + "\n");
		}
	}

	public class Visitor : Valadoc.Api.Visitor {
		public override void visit_class (Valadoc.Api.Class item) {
			print ("visit class\n\n");
			base.visit_class (item);
		}
			public override void visit_constant (Valadoc.Api.Constant item) {}
			public override void visit_delegate (Valadoc.Api.Delegate item) {}
			public override void visit_enum (Valadoc.Api.Enum item) {}
			public override void visit_enum_value (Valadoc.Api.EnumValue item) {}
			public override void visit_error_code (Valadoc.Api.ErrorCode item) {}
			public override void visit_error_domain (Valadoc.Api.ErrorDomain item) {}
			public override void visit_field (Valadoc.Api.Field item) {}
			public override void visit_formal_parameter (Valadoc.Api.FormalParameter item) {}
			public override void visit_interface (Valadoc.Api.Interface item) {}
			public override void visit_method (Valadoc.Api.Method item) {}
			public override void visit_namespace (Valadoc.Api.Namespace item) {
				print ("namespace\n");
				base.visit_namespace (item);
			}
			public override void visit_package (Valadoc.Api.Package item) {
				print ("package\n");
				base.visit_package (item);
			}
			public override void visit_property (Valadoc.Api.Property item) {}
			public override void visit_signal (Valadoc.Api.Signal item) {}
			public override void visit_struct (Valadoc.Api.Struct item) {}
			public override void visit_tree (Valadoc.Api.Tree item) {
				print ("tree\n");
				base.visit_tree (item);
			}
			public override void visit_type_parameter (Valadoc.Api.TypeParameter item) {}
	}
}