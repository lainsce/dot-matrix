namespace DotMatrix {
    [GtkTemplate (ui = "/io/github/lainsce/DotMatrix/prefs.ui")]
    public class Prefs : Adw.PreferencesWindow {
        public int width { get; set; }
        public int height { get; set; }

        [GtkChild]
        public unowned Gtk.Entry height_entry;
        [GtkChild]
        public unowned Gtk.Entry width_entry;

        construct {
            var settings = new Settings ();
            width_entry.activate.connect (() => {
                settings.canvas_width = int.parse(width_entry.get_text ());
            });

            height_entry.activate.connect (() => {
                settings.canvas_height = int.parse(height_entry.get_text ());
            });
        }
    }
}
