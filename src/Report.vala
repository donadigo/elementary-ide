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
	public enum ReportType {
		NOTE = 0,
		DEPRECATION,
		WARNING,
		ERROR
	}

	public class ReportMessage : Object {
		public ReportType report_type;
		public string message;
		public Vala.SourceReference? source;

		public ReportMessage (ReportType report_type, string message, Vala.SourceReference? source) {
			this.report_type = report_type;
			this.message = message;
			this.source = source;
		}
	}

	public class Report : Vala.Report {
		public List<ReportMessage> messages;

		construct {
			messages = new List<ReportMessage> ();
		}

		public void clear () {
			messages = new List<ReportMessage> ();

			this.errors = 0;
			this.warnings = 0;			
		}

		public void get_message_count (out int errors, out int warnings) {
			errors = this.errors;
			warnings = this.warnings;
		}

		public override void note (Vala.SourceReference? source, string message) {
			if (source == null) {
				return;
			}

			var report_message = new ReportMessage (ReportType.NOTE, message, source);
			messages.append (report_message);
		}

		public override void depr (Vala.SourceReference? source, string message) {
			warnings++;
			if (source == null) {
				return;
			}

			var report_message = new ReportMessage (ReportType.DEPRECATION, message, source);
			messages.append (report_message);			
		}
		
		public override void warn (Vala.SourceReference? source, string message) {
			warnings++;
			if (source == null) {
				return;
			}

			var report_message = new ReportMessage (ReportType.WARNING, message, source);
			messages.append (report_message);				
		}
		
		public override void err (Vala.SourceReference? source, string message) {
			errors++;
			if (source == null) {
				return;
			}

			var report_message = new ReportMessage (ReportType.ERROR, message, source);
			messages.append (report_message);				
		}		
	}
}