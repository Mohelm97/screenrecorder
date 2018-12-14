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
    public class VideoPlayer : Gtk.Grid  {
        private string fileuri;
        private Gst.Element player;
        private Gst.Element sink;
        private Gtk.Image image;
        private int resize_width  = 0;
        private int resize_height = 0;
        private int max_width;
        private int max_height;

        public VideoPlayer (string filepath, int max_width, int max_height) {
            image = new Gtk.Image ();
            add (image);
            show.connect (create_sink_and_play);
            destroy.connect (stop_and_destroy);
            this.fileuri = "file://"+filepath;
            this.max_width = max_width;
            this.max_height = max_height;
        }

        private void create_sink_and_play () {
            player = Gst.ElementFactory.make ("playbin", "playbin");
            sink = Gst.ElementFactory.make ("gdkpixbufsink", "sink");
            player["video-sink"] = sink;
            player["uri"] = fileuri;
            player.set_state (Gst.State.PLAYING);
            
            // Simple ugly loop :)
            uint64 last_position = 0;
            Timeout.add (500, () => {
                if (player != null) {
                    uint64 position;
                    player.query_position (Gst.Format.TIME, out position);
                    if (position == last_position && last_position != 0) {
                        player.seek_simple (Gst.Format.TIME, Gst.SeekFlags.FLUSH | Gst.SeekFlags.SEGMENT, 0);
                    }
                    last_position = position;
                }
                return visible;
            });

            Timeout.add (10, () => {
                if (player != null) {
                    Gdk.Pixbuf pixbuf;
                    sink.get ("last-pixbuf", out pixbuf);

                    // Just calculate the prefered width, height at the first frame.
                    if (resize_width == 0 && pixbuf != null){
                        int width = pixbuf.get_width ();
                        int height = pixbuf.get_height () ;
                        if (width > height) {
                            width = int.min (width, max_width);
                            height = width * height / pixbuf.get_width ();
                        } else {
                            height = int.min (height, max_height);
                            width = height * width / pixbuf.get_height ();
                        }

                        var scale = get_style_context ().get_scale ();
                        resize_width = width * scale;
                        resize_height = height * scale;
                    }

                    if (pixbuf != null) {
                        image.pixbuf = pixbuf.scale_simple (resize_width, resize_height, Gdk.InterpType.BILINEAR);
                    }

                }
                return visible;
            });
        }

        private void stop_and_destroy () {
            player.set_state (Gst.State.NULL);
            sink.set_state (Gst.State.NULL);
            player = null;
            sink = null;
        }

    }
}
