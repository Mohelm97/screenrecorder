/*
 * Copyright (c) 2014–2016 Fabio Zaramella <ffabio.96.x@gmail.com>
 *               2017–2018 elementary LLC. (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License version 3 as published by the Free Software Foundation.
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
 *              Artem Anufrij <artem.anufrij@live.de>
 *              Fabio Zaramella <ffabio.96.x@gmail.com>
 */

namespace ScreenRecorder {

    public class SaveDialog : Gtk.Dialog {

        public string filepath { get; construct; }
        public int expected_width {get; construct;}
        public int expected_height {get; construct;}

        private Gtk.Entry name_entry;
        private Gtk.Button save_btn;
        private VideoPlayer preview;
        private FormatComboBox format_cmb;
        private string folder_dir = Environment.get_user_special_dir (UserDirectory.VIDEOS)
        +  "%c".printf(GLib.Path.DIR_SEPARATOR) + ScreenRecorderApp.SAVE_FOLDER;

        public SaveDialog (string filepath, Gtk.Window parent, int expected_width, int expected_height) {
            Object (
                border_width: 6,
                deletable: false,
                modal: true,
                resizable: false,
                title: parent.title,
                transient_for: parent,
                filepath: filepath,
                expected_width: expected_width,
                expected_height: expected_height
            );

            response.connect (manage_response);
            close.connect (remove_temp);
        }

        construct {
            GLib.Settings settings = ScreenRecorderApp.settings;
            Gdk.Rectangle selection_rect;
            Gdk.get_default_root_window ().get_frame_extents (out selection_rect);
            int max_width_height = selection_rect.height*46/100;
            debug ("Max width/height: %d",max_width_height);
            preview = new VideoPlayer (filepath, expected_width, expected_height, max_width_height);

            var preview_box = new Gtk.Grid ();
            preview_box.halign = Gtk.Align.CENTER;
            preview_box.add (preview);

            var preview_box_context = preview_box.get_style_context ();
            preview_box_context.add_class ("card");
            //preview_box_context.add_class ("checkerboard-layout");

            var dialog_label = new Gtk.Label (_("Save record as…"));
            dialog_label.get_style_context ().add_class ("h4");
            dialog_label.halign = Gtk.Align.START;

            var name_label = new Gtk.Label (_("Name:"));
            name_label.halign = Gtk.Align.END;

            var recording_scale = (double) settings.get_int ("scale") / 100;
            var screen_scale = this.scale_factor;
            var file_name = get_file_name (recording_scale, screen_scale);

            name_entry = new Gtk.Entry ();
            name_entry.hexpand = true;
            name_entry.text = file_name;

            var format_label = new Gtk.Label (_("Format:"));
            format_label.halign = Gtk.Align.END;

            format_cmb = new FormatComboBox ();

            var location_label = new Gtk.Label (_("Folder:"));
            location_label.halign = Gtk.Align.END;

            var folder_from_settings = settings.get_string ("folder-dir");

            if (folder_from_settings != folder_dir && folder_from_settings != "") {
                folder_dir = folder_from_settings;
            }
            ScreenRecorderApp.create_dir_if_missing (folder_dir);

            var location = new Gtk.FileChooserButton (_("Select Screen Records Folder…"), Gtk.FileChooserAction.SELECT_FOLDER);
            location.set_current_folder (folder_dir);

            var grid = new Gtk.Grid ();
            grid.margin = 6;
            grid.margin_top = 0;
            grid.margin_bottom = 12;
            grid.row_spacing = 12;
            grid.column_spacing = 12;
            grid.attach (preview_box, 0, 0, 2, 1);
            grid.attach (dialog_label, 0, 1, 2, 1);
            grid.attach (name_label, 0, 2, 1, 1);
            grid.attach (name_entry, 1, 2, 1, 1);
            grid.attach (format_label, 0, 3, 1, 1);
            grid.attach (format_cmb, 1, 3, 1, 1);
            grid.attach (location_label, 0, 4, 1, 1);
            grid.attach (location, 1, 4, 1, 1);

            var content = this.get_content_area () as Gtk.Box;
            content.add (grid);

            add_button (_("Cancel"), 0);

            var save_original_btn = add_button (_("Save Original"), 1);

            save_btn = add_button (_("Save"), 2) as Gtk.Button;
            save_btn.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            settings.bind ("format", format_cmb, "text_value", GLib.SettingsBindFlags.DEFAULT);
            format_cmb.sensitive = false;
            save_original_btn.sensitive = (format_cmb.get_active_text () != "gif");
            location.selection_changed.connect (() => {
                SList<string> uris = location.get_uris ();
                foreach (unowned string uri in uris) {
                    settings.set_string ("folder-dir", Uri.unescape_string (uri.substring (7, -1)));
                    folder_dir = settings.get_string ("folder-dir");
                }
            });

            key_press_event.connect ((e) => {
                if (e.keyval == Gdk.Key.Return) {
                    manage_response (2);
                }

                return false;
            });
        }

        private void manage_response (int response_id) {
            if (response_id == 1) {
                debug ("Oi Oi you got a license for that copy");
                File tmp_file = File.new_for_path (filepath);
                string file_name = Path.build_filename (folder_dir, "%s.%s".printf (name_entry.get_text (), format_cmb.get_active_text ()));
                File save_file = File.new_for_path (file_name);
                try {
                    tmp_file.copy (save_file, 0, null, null);
                } catch (Error e) {
                    print ("Error: %s\n", e.message);
                }
                close ();
            } else if (response_id == 2) {
                save_btn.always_show_image = true;
                var spinner = new Gtk.Spinner ();
                save_btn.set_image (spinner);
                spinner.start ();
                sensitive = false;
                string save_filepath = Path.build_filename (folder_dir, "%s.%s".printf (name_entry.get_text (), format_cmb.get_active_text ()));
                FFmpegWrapper.render_file.begin (filepath, save_filepath, format_cmb.get_active_text (), (obj, res) => {
                    sensitive = true;
                    save_btn.set_image (null);
                    debug ("Render done");
                    close ();
                });
            } else {
                close ();
            }
        }

        private void remove_temp () {
            GLib.FileUtils.remove (filepath);
        }

        /**
         * Generate file name
         * When appropriate include a scale hint that websites can use to 
         * scale down recordings on higher dpi screens. 
         */
        private string get_file_name (double recording_scale, double screen_scale) {
            var date_time = new GLib.DateTime.now_local ().format ("%Y-%m-%d %H.%M.%S");

            /// TRANSLATORS: %s represents a timestamp here
            var file_name = _("Screen record from %s").printf (date_time);
            var file_scale = get_file_scale (recording_scale, screen_scale);
            if (file_scale > 1) {
                file_name += "@%ix".printf (file_scale);
            }
            return file_name;
        }

        private int get_file_scale (double recording_scale, double screen_scale) {
            var file_scale = screen_scale * recording_scale;
            // never make it seem like images are taken on higher dpi screen
            file_scale = (file_scale > screen_scale)? screen_scale : file_scale;
            file_scale = (file_scale < 1)? 1 : file_scale;
            return (int) file_scale;
        }
    }
}
