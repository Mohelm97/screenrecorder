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
        private ClutterGst.Playback playback;
        private GtkClutter.Embed clutter;
        private Clutter.Actor video_actor;
        private Clutter.Stage stage;

        public VideoPlayer (string filepath) {
            show.connect (create_sink_and_play);
            destroy.connect (stop_and_destroy);
            this.fileuri = "file://"+filepath;
        }

        private void create_sink_and_play () {
            playback = new ClutterGst.Playback ();
            playback.eos.connect (() => {
                playback.progress = 0;
                playback.playing = true;
            });
            playback.set_seek_flags (ClutterGst.SeekFlags.ACCURATE);

            clutter = new GtkClutter.Embed ();

            stage = (Clutter.Stage) clutter.get_stage ();
            stage.background_color = {0, 0, 0, 0};

            video_actor = new Clutter.Actor ();

            #if VALA_0_34
                var aspect_ratio = new ClutterGst.Aspectratio ();
            #else
                var aspect_ratio = ClutterGst.Aspectratio.@new ();
            #endif

            ((ClutterGst.Aspectratio) aspect_ratio).paint_borders = false;
            ((ClutterGst.Content) aspect_ratio).player = playback;
            video_actor.content = aspect_ratio;

            video_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 0));
            video_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.HEIGHT, 0));

            stage.add_child (video_actor);

            add (clutter);
            show_all ();

            playback.uri = fileuri;
            playback.playing = true;
        }

        private void stop_and_destroy () {
            playback.playing = false;
            playback.uri = null;
        }

    }
}
