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
	public class CMakeBuildSystem : Object, BuildSystem {
		private const string TARGET = "CMakeLists.txt";

		public Project project { get; set; }

		public CMakeBuildSystem (Project project) {
			this.project = project;
		}

		public void build () throws Error {

		}

		public void clean () throws Error {
			
		}		

		public void run_binary () throws Error {
			
		}		

		public string[] get_external_packages () {
			return {};
		}

		public string[] get_source_packages () {
			return {};
		}
	}
}