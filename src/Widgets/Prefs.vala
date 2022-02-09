namespace DotMatrix {
    [GtkTemplate (ui = "/io/github/lainsce/DotMatrix/prefs.ui")]
    public class Prefs : Adw.PreferencesWindow {
        public int width { get; set; }
        public int height { get; set; }
        public int thickness { get; set; }
        public bool close_paths { get; set; default=false;}

        [GtkChild]
        public unowned Gtk.Entry height_entry;
        [GtkChild]
        public unowned Gtk.Entry width_entry;
        [GtkChild]
        public unowned Gtk.SpinButton line_thickness_button;
        [GtkChild]
        public unowned Gtk.Switch close_paths_switch;

        construct {
            var settings = new Settings ();
            width_entry.activate.connect (() => {
                settings.canvas_width = int.parse(width_entry.get_text ());
            });

            height_entry.activate.connect (() => {
                settings.canvas_height = int.parse(height_entry.get_text ());
            });

            line_thickness_button.value_changed.connect ((e) => {
                settings.thickness = (int)line_thickness_button.get_value ();
            });

            close_paths_switch.notify["active"].connect (() => {
                if (close_paths) {
					settings.close_paths = false;
				} else {
					settings.close_paths = true;
				}
            });
        }
    }
}
