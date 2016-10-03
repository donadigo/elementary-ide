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
    public class WordCompletionProvider : Gtk.SourceCompletionProvider, Object {
        private Gtk.TextBuffer buffer;

        private const string START_MARK_NAME = "WordCompletionStart";
        private const string END_MARK_NAME = "WordCompletionEnd";
        private const uint MIN_WORD_SIZE = 3;

        private Gtk.TextMark completion_end_mark;
        private Gtk.TextMark completion_start_mark;

        private List<Gtk.SourceCompletionProposal> proposals;

        public WordCompletionProvider (Gtk.TextBuffer text_buffer) {
            buffer = text_buffer;

            proposals = new List<Gtk.SourceCompletionProposal> ();

            Gtk.TextIter iter;
            buffer.get_iter_at_offset (out iter, 0);
            completion_start_mark = buffer.create_mark (START_MARK_NAME, iter, false);
            completion_end_mark = buffer.create_mark (END_MARK_NAME, iter, false);
        }

        public string get_name () {
            return "WordCompletionProvider";
        }

        public int get_priority () {
            return 0;
        }

        public bool match (Gtk.SourceCompletionContext context) {
            return true;
        }   

        public void populate (Gtk.SourceCompletionContext context) {
            Gtk.TextIter iter;
            if (!context.get_iter (out iter)) {
                context.add_proposals (this, null, true);
                return;
            }

            var start_line = iter;
            start_line.set_line_offset (0);

            string line_text = buffer.get_text (start_line, iter, false);
            string? word = get_last_word_from_string (line_text);
            if (word != null) {
                var proposal = new Gtk.SourceCompletionItem (word, word, null, null);
                proposals.append (proposal);
            }

            context.add_proposals (this, proposals, true);            
        }

        private string? get_last_word_from_string (string str) {
            if (!str.contains (" ")) {
                return null;
            }

            string[] arr = str.split (" ");
            if (arr.length < 2) {
                return null;
            }

            char[] utf8 = arr[arr.length - 2].to_utf8 ();
            if (utf8.length < MIN_WORD_SIZE) {
                return null;
            }

            string buff = "";
            foreach (char ch in utf8) {
                if (ch.isprint () && (ch == '_' || ch.isalnum ())) {
                    buff += ch.to_string ();
                } else {
                    break;
                }
            }

            return buff;
        }

        public bool activate_proposal (Gtk.SourceCompletionProposal proposal, Gtk.TextIter iter) {
            Gtk.TextIter start;
            Gtk.TextIter end;
            Gtk.TextMark mark;

            mark = buffer.get_mark (END_MARK_NAME);
            buffer.get_iter_at_mark (out end, mark);

            mark = buffer.get_mark (START_MARK_NAME);
            buffer.get_iter_at_mark (out start, mark);

            buffer.delete (ref start, ref end);
            buffer.insert (ref start, proposal.get_text (), proposal.get_text ().length);

            return true;
        }

        public void update_info (Gtk.SourceCompletionProposal proposal, Gtk.SourceCompletionInfo info) {
            /* No additional info provided on proposals */
            return;
        }

        public int get_interactive_delay () {
            return 100;
        }

        public Gtk.SourceCompletionActivation get_activation () {
            return Gtk.SourceCompletionActivation.INTERACTIVE;
        }

        public unowned Gtk.Widget? get_info_widget (Gtk.SourceCompletionProposal proposal) {
            /* As no additional info is provided no widget is needed */
            return null;
        }
    }
}