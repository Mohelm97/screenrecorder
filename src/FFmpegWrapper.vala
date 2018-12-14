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
    public class FFmpegWrapper : GLib.Object {
        private Subprocess? subprocess;

        public FFmpegWrapper (string filepath, string ext, int framerate, int start_x, int start_y, int width, int height, bool show_mouse, bool show_borders){
            try {
                string display = Environment.get_variable ("DISPLAY");
                if (display == null) {
                  display = ":0";
                }
                string[] spawn_args = {
                    "ffmpeg",
                    "-y",
                    "-video_size", "%ix%i".printf (width, height),
                    "-framerate", framerate.to_string (),
                    "-show_region", show_borders?"1":"0",
                    "-region_border", "2",
                    "-draw_mouse", show_mouse?"1":"0",
                    "-f", "x11grab",
                    "-i", "%s+%i,%i".printf (display, start_x, start_y),
                    filepath
                };
                SubprocessLauncher launcher = new SubprocessLauncher (SubprocessFlags.STDERR_PIPE);
                subprocess = launcher.spawnv (spawn_args);
            } catch (Error e) {
                GLib.warning (e.message);
            }
        }

        public void stop () {
            subprocess.send_signal (2);
            try {
                subprocess.wait ();
            } catch (Error e) {
                warning (e.message);
            }
        }
    }
}
