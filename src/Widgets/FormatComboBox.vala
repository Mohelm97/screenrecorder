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
* Authored by: Mohammed ALMadhoun <mohelm97@gmail.com>
*/

namespace ScreenRecorder {
    public class FormatComboBox : Gtk.ComboBoxText {
        public FormatComboBox (string selected) {
            append_text ("mp4");
            append_text ("ogv");
            append_text ("mov");
            append_text ("gif");

            switch (selected) {
                case "mp4":
                    active = 0;
                    break;
                case "ogv":
                    active = 1;
                    break;
                case "mov":
                    active = 2;
                    break;
                case "gif":
                    active = 3;
                    break;
            }
        }
    }
}
