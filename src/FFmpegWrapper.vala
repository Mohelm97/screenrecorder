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

        public FFmpegWrapper (
            string filepath,
            string ext,
            int framerate,
            int start_x,
            int start_y,
            int width,
            int height,
            bool show_mouse,
            bool show_borders,
            bool record_cmp,
            bool record_mic){
            try {
                width = width + (width % 2);
                height = height + (height % 2);
                string display = Environment.get_variable ("DISPLAY");
                if (display == null) {
                  display = ":0";
                }
                bool is_gif = (ext == "gif");
                string[] spawn_args = {
                    "ffmpeg",
                    "-y",
                    "-video_size", "%ix%i".printf (width, height),
                    "-framerate", framerate.to_string (),
                    "-show_region", show_borders?"1":"0",
                    "-region_border", "2",
                    "-draw_mouse", show_mouse?"1":"0",
                    "-f", "x11grab",
                    "-i", "%s+%i,%i".printf (display, start_x, start_y)
                };
                if (record_mic && !is_gif) {
                    spawn_args += "-f";
                    spawn_args += "pulse";
                    spawn_args += "-i";
                    spawn_args += "default";
                }
                if (record_cmp && !is_gif) {
                    string default_audio_output = get_default_audio_output ();
                    if (default_audio_output != "") {
                        spawn_args += "-f";
                        spawn_args += "pulse";
                        spawn_args += "-i";
                        spawn_args += default_audio_output;
                        if (record_mic) {
                            spawn_args += "-filter_complex";
                            spawn_args += "amerge";
                            spawn_args += "-ac";
                            spawn_args += "2";
                        }
                    }
                }
                spawn_args += "-preset";
                spawn_args += "ultrafast";
                spawn_args += filepath;

                debug ("ffmpeg command: %s",string.joinv(" ", spawn_args));
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

        string get_default_audio_output () {
            /*-
             * Copyright (c) 2011-2015 Eidete Developers
             * Copyright (c) 2017-2018 Artem Anufrij <artem.anufrij@live.de>
             * https://github.com/artemanufrij/screencast
             */
            string default_output = "";
            try {
                string sound_outputs = "";
                Process.spawn_command_line_sync ("pacmd list-sinks", out sound_outputs);
                GLib.Regex re = new GLib.Regex ("(?<=\\*\\sindex:\\s\\d\\s\\sname:\\s<)[\\w\\.\\-]*");
                MatchInfo mi;
                if (re.match (sound_outputs, 0, out mi)) {
                    default_output = mi.fetch (0);
                }
            } catch (Error e) {
                warning (e.message);
            }
            return default_output+".monitor";
        }

        public static async bool render_file (string inputpath, string outputpath, string extension) {
            bool return_value = false;
            try {
                string[] spawn_args = {
                    "ffmpeg",
                    "-i", inputpath,
                    "-pix_fmt", "yuv420p",
                    outputpath
                };
                if (extension == "gif") {
                    spawn_args = {
                        "ffmpeg",
                        "-i",
                        inputpath,
                        "-filter_complex",
                        "[0:v] split [a][b];[a] palettegen [p];[b][p] paletteuse",
                        outputpath
                    };
                }
                debug ("ffmpeg command: %s",string.joinv(" ", spawn_args));
                SubprocessLauncher launcher = new SubprocessLauncher (SubprocessFlags.STDERR_PIPE);
                Subprocess? render_subprocess = launcher.spawnv (spawn_args);
                return_value = yield render_subprocess.wait_check_async ();
            } catch (Error e) {
                GLib.warning (e.message);
            }
            return return_value;
        }
    }
}
