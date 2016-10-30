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
    public interface DocumentManager : Object {
        public abstract Project? get_project ();
        public abstract CodeParser get_code_parser ();
        public abstract Document? get_current_document ();
        public abstract Gee.List<Document> get_opened_documents ();
        public abstract void load_project (Project? project);


        public virtual signal void add_document (Document document, bool focus = true) {

        }

        public virtual signal void remove_document (Document document) {

        }

        public virtual signal void current_document_changed () {

        }

        public virtual signal void queue_parse () {

        }
    }
}