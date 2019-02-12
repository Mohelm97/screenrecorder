/*
* Copyright (c) 2018 mohelm97 (https://github.com/mohelm97/screenrecorder)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Peter Uithoven <peter@peteruithoven.nl>
*/

namespace ScreenRecorder {
    public class ScaleComboBox : Gtk.ComboBoxText {
        public int scale {
            get {
                return int.parse (active_id);
            }
            set {
                active_id = value.to_string ();
            }
        }
        public ScaleComboBox () {
            int [] scales = { 25, 50, 75, 100, 200 };
            foreach (int scale in scales) {
                var scale_id = scale.to_string();
                append (scale_id, scale_id + "%");
            }
            changed.connect(() => {
                scale = scale;
            });
        }
    }
}
