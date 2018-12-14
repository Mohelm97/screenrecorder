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
    public class VideoPlayer : Gtk.Image  {
        private string fileuri;
        public VideoPlayer (string fileuri) {
            show.connect (create_sink_and_play);
            this.fileuri = fileuri;
        }
        
        private void create_sink_and_play () {
            var player = Gst.ElementFactory.make ("playbin", "playbin");
            var sink = Gst.ElementFactory.make ("gdkpixbufsink", "sink");
            player["video-sink"] = sink;
            player["uri"] = fileuri;
            player.set_state (Gst.State.PLAYING);
            Timeout.add (5, () => {
                Gdk.Pixbuf pb;
                sink.get ("last-pixbuf", out pb);
                pixbuf = pb;
                return true;
            });
        }
    }
}
