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
    public class VideoPlayer : Gtk.Box  {
        private string fileuri;
        private ClutterGst.Playback playback;
        private GtkClutter.Embed clutter;
        private Clutter.Actor video_actor;
        private Clutter.Stage stage;
        private int max_width_height;
        private int expected_width;
        private int expected_height;

        public VideoPlayer (string filepath, int expected_width, int expected_height, int max_width_height) {
            Object (
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 0
            );
            this.expected_width = expected_width;
            this.expected_height = expected_height;
            this.max_width_height = max_width_height;

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
            int width = expected_width;
            int height = expected_height;
            var scale = get_style_context ().get_scale ();
            if (width > height) {
                width = int.min (width, max_width_height * scale);
                height = width * height / expected_width;
            } else {
                height = int.min (height, max_width_height * scale);
                width = height * width / expected_height;
            }
            clutter.set_size_request (width / scale, height / scale);

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

            var action_bar = new Gtk.ActionBar ();
            var seek_bar = new Granite.SeekBar (playback.get_duration ());
            seek_bar.valign = Gtk.Align.CENTER;
            // Set min-width and height to zero so the player goes where you click.
            // This should be remove if this PR merged: https://github.com/elementary/stylesheet/pull/457
            try {
                var slider_css = new Gtk.CssProvider();
                slider_css.load_from_data ("slider {min-width:0;min-height:0;}");
                seek_bar.scale.get_style_context ().add_provider (slider_css, Gtk.STYLE_PROVIDER_PRIORITY_USER+1);
            } catch (Error e) {}

            var play_button = new Gtk.Button.from_icon_name ("media-playback-pause-symbolic", Gtk.IconSize.BUTTON);
            play_button.tooltip_text = _("Toggle playing");
            play_button.clicked.connect (() => {
                playback.playing = !playback.playing;
                if (playback.playing) {
                    ((Gtk.Image) play_button.image).icon_name = "media-playback-pause-symbolic";
                } else {
                    ((Gtk.Image) play_button.image).icon_name = "media-playback-start-symbolic";
                }
            });
            action_bar.pack_start (play_button);
            action_bar.set_center_widget (seek_bar);
            
            playback.bind_property ("duration", seek_bar, "playback_duration");
            seek_bar.button_release_event.connect ((event) => {
                playback.progress = seek_bar.playback_progress;
                return false;
            });
            playback.notify["progress"].connect (() => {
                if (!seek_bar.is_grabbing) {
                    seek_bar.playback_progress = playback.progress;
                }
            });

            playback.uri = fileuri;
            playback.playing = true;

            add (clutter);
            add (action_bar);
            show_all ();
        }

        private void stop_and_destroy () {
            playback.playing = false;
            playback.uri = null;
        }
        
        public override void get_preferred_width (out int minimum_width, out int natural_width) {
            minimum_width = clutter.width_request;
            natural_width = clutter.width_request;
        }

    }
}
