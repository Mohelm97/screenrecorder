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
    public class ScreenRecorderApp : Gtk.Application {
        public static GLib.Settings settings;
        private MainWindow window = null;

        public const string SAVE_FOLDER = _("Screen Records");

        public ScreenRecorderApp () {
            Object (
                application_id: "com.github.mohelm97.screenrecorder",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }
        
        construct {
            settings = new GLib.Settings ("com.github.mohelm97.screenrecorder");
            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
            default_theme.add_resource_path ("/com/github/mohelm97/screenrecorder");
            var quit_action = new SimpleAction ("quit", null);
            quit_action.activate.connect (() => {
                if (window != null) {
                    window.destroy ();
                }
            });

            var open_records_folder_action = new SimpleAction ("open-records-folder", VariantType.STRING);
            open_records_folder_action.activate.connect ((parameter) => {
                if (parameter == null) {
                    return;
                }
                try {
                    File records_folder = File.new_for_path (settings.get_string ("folder-dir"));
                    AppInfo.launch_default_for_uri (records_folder.get_uri (), null);
                    debug("launch_default_for_uri %s".printf (parameter.get_string ()));
                } catch (Error e) {
                    GLib.warning (e.message);
                }
            });

            add_action (quit_action);
            add_action (open_records_folder_action);
            set_accels_for_action ("app.quit", {"<Control>q"});
        }

        protected override void activate () {
            if (window != null) {
                window.present ();
                return;
            }
            window = new MainWindow (this);
            window.get_style_context ().add_class ("rounded");
            window.show_all ();
        }

        public static int main (string[] args) {
            Gtk.init (ref args);
            Gst.init (ref args);
            var err = GtkClutter.init (ref args);
            if (err != Clutter.InitError.SUCCESS) {
                error ("Could not initalize clutter! "+err.to_string ());
            }
            var app = new ScreenRecorderApp ();
            return app.run (args);
        }

        public static void create_dir_if_missing (string path) {
            if (!File.new_for_path (path).query_exists ()) {
                try {
                    File file = File.new_for_path (path);
                    file.make_directory ();
                } catch (Error e) {
                    debug (e.message);
                }
            }
        }
    }
}
