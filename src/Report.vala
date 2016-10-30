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
        DEPRECATED,
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

        public unowned string? to_icon_name () {
            switch (report_type) {
                case ReportType.WARNING:
                case ReportType.DEPRECATED:
                    return "dialog-warning";
                case ReportType.ERROR:
                    return "dialog-error";
                case ReportType.NOTE:
                    return "dialog-information";
                default:
                    break;
            }

            return null;
        }
    }

    public class Report : Vala.Report {
        private Gee.ArrayList<ReportMessage> messages;

        construct {
            messages = new Gee.ArrayList<ReportMessage> ();
        }

        public void clear () {
            this.errors = 0;
            this.warnings = 0;          
        }

        public void reset_file (Vala.SourceFile target) {
            var removal_list = new Gee.ArrayList<ReportMessage> ();
            foreach (var message in messages) {
                if (message.source.file.filename == target.filename) {
                    removal_list.add (message);
                }
            }

            messages.remove_all (removal_list);
        }

        public void get_message_count (out int _errors, out int _warnings) {
            _errors = 0;
            _warnings = 0;

            foreach (var message in messages) {
                switch (message.report_type) {
                    case ReportType.ERROR:
                        _errors++;
                        break;
                    case ReportType.WARNING:
                    case ReportType.DEPRECATED:
                        _warnings++;
                        break;                        
                }
            }
        }

        public unowned Gee.ArrayList<ReportMessage> get_messages () {
            return messages;
        }

        public override void note (Vala.SourceReference? source, string message) {
            if (source == null) {
                return;
            }

            var report_message = new ReportMessage (ReportType.NOTE, message, source);
            messages.add (report_message);
        }

        public override void depr (Vala.SourceReference? source, string message) {
            warnings++;
            if (source == null) {
                return;
            }

            var report_message = new ReportMessage (ReportType.DEPRECATED, message, source);
            messages.add (report_message);          
        }
        
        public override void warn (Vala.SourceReference? source, string message) {
            warnings++;
            if (source == null) {
                return;
            }

            print ("warn: %s\n", message);
            var report_message = new ReportMessage (ReportType.WARNING, message, source);
            messages.add (report_message);              
        }
        
        public override void err (Vala.SourceReference? source, string message) {
            errors++;
            if (source == null) {
                return;
            }

            print ("err: %s\n", message);
            var report_message = new ReportMessage (ReportType.ERROR, message, source);
            messages.add (report_message);              
        }       
    }
} 