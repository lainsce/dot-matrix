/*
* Copyright (c) 2019 Lains
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
*/
namespace DotMatrix {
    public class MainWindow : Gtk.Window {
        public Widgets.UI grid;
        public Gtk.HeaderBar titlebar;
        public Gtk.ActionBar actionbar;
        public Granite.ModeSwitch mode_switch;
        private int uid;
        private static int uid_counter = 0;

        // Global Color Palette
        public string background = "#EEEEEE";
        public string f_high = "#000000";
        public string f_med = "#999999";
        public string f_low = "#CCCCCC";
        public string f_inv = "#000000";
        public string b_high = "#000000";
        public string b_med = "#888888";
        public string b_low = "#AAAAAA";
        public string b_inv = "#FFB545";


        private const Gtk.TargetEntry [] targets = {{
            "text/uri-list", 0, 0
        }};

        public MainWindow (Gtk.Application application) {
            GLib.Object (
                application: application,
                icon_name: "com.github.lainsce.dot-matrix",
                height_request: 780,
                width_request: 810,
                title: (_("Dot Matrix"))
            );

            key_press_event.connect ((e) => {
                uint keycode = e.hardware_keycode;

                if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                    if (match_keycode (Gdk.Key.q, keycode)) {
                        this.destroy ();
                    }

                    if (match_keycode (Gdk.Key.z, keycode)) {
                        grid.undo ();
                        grid.current_path = new Path ();
				        grid.da.queue_draw ();
                    }
                }
                return false;
            });

            this.uid = uid_counter++;
            string css_light = """
                        @define-color colorPrimary %s;
                        @define-color colorSecondary %s;
                        @define-color colorAccent %s;
                        @define-color windowPrimary %s;
                        @define-color textColorPrimary %s;
                        @define-color textColorSecondary %s;

                        .dm-window {
                            background: @colorPrimary;
                            color: @textColorPrimary;
                        }

                        .dm-toolbar {
                            background: @colorPrimary;
                            color: @windowPrimary;
                            box-shadow: 0 1px transparent inset;
                        }

                        .dm-actionbar {
                            background: @colorPrimary;
                            box-shadow: 0 1px transparent inset;
                            color: @textColorSecondary;
                            padding: 8px;
                            border-top: 1px solid alpha (@textColorPrimary, 0);
                        }

                        .dm-actionbar image {
                            color: @textColorSecondary;
                        }

                        .dm-actionbar button:hover {
                            background: @colorSecondary;
                        }

                        .dm-actionbar button:active {
                            background: @colorAccent;
                        }

                        .dm-reverse image {
                            -gtk-icon-transform: rotate(180deg);
                        }

                        .dm-grid {
                            background: @colorPrimary;
                        }

                        .dm-text {
                            font-family: 'Cousine', Courier, monospace;
                            font-size: 1.66em;
                        }

                        .dm-clrbtn {
                            background: @colorPrimary;
                            color: @textColorPrimary;
                            box-shadow: 0 1px transparent inset;
                            border: none;
                        }

                        .dm-clrbtn:active {
                            background: @colorAccent;
                        }

                        .dm-clrbtn colorswatch {
                            border-radius: 8px;
                        }
                    """.printf(this.background, this.b_inv, this.b_med, this.b_high, this.b_high, this.b_high);
                    try {
                        var provider = new Gtk.CssProvider ();
                        provider.load_from_data (css_light, -1);
                        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),provider,Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
                    } catch {}
        }

        construct {
            var settings = AppSettings.get_default ();
            int x = settings.window_x;
            int y = settings.window_y;
            if (x != -1 && y != -1) {
                this.move (x, y);
            }

            this.get_style_context ().add_class ("rounded");
            this.get_style_context ().add_class ("dm-window");

            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
            default_theme.add_resource_path ("/com/github/lainsce/dot-matrix");

            titlebar = new Gtk.HeaderBar ();
            titlebar.show_close_button = true;
            titlebar.has_subtitle = false;
            var titlebar_style_context = titlebar.get_style_context ();
            titlebar_style_context.add_class (Gtk.STYLE_CLASS_FLAT);
            titlebar_style_context.add_class ("dm-toolbar");
            this.set_titlebar (titlebar);

            var scrolled = new Gtk.ScrolledWindow (null, null);
            grid = new Widgets.UI (this);
            grid.line_color.parse (this.f_high);
			grid.grid_dot_color.parse (this.f_med);
			grid.background_color.parse (this.background);
			grid.line_color_button.rgba = grid.line_color;
            scrolled.add (grid);
            scrolled.expand = true;

            actionbar = new Gtk.ActionBar ();
			actionbar.get_style_context ().add_class ("dm-actionbar");

            var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.expand = true;
            grid.attach (scrolled, 1, 0, 1, 1);
            grid.show_all ();

            Gtk.drag_dest_set (this,Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY);
            this.drag_data_received.connect(this.on_drag_data_received);
            this.add (grid);
            this.show_all ();
        }

        private void on_drag_data_received (Gdk.DragContext drag_context, int x, int y, 
                                        Gtk.SelectionData data, uint info, uint time) {
            foreach(string uri in data.get_uris ()) {
                string file = uri.replace ("file://","").replace ("file:/","");
                file = Uri.unescape_string (file);
                print ("Got file!\n");
                get_colors_from_svg (file);
            }
            Gtk.drag_finish (drag_context, true, false, time);
        }

        public void get_colors_from_svg (string file) {
            string regString = "id='(?<id>.*)' fill='(?<color>#[A-Fa-f0-9]{6})\'";
            string input = "";
            try {
                GLib.FileUtils.get_contents (file, out input, null);
            } catch {}

            Regex regex;
            MatchInfo match;
            try {
                regex = new Regex (regString);
                if (regex.match (input, 0, out match)) {
                    do {
                        if (match.fetch_named ("id") == "background") {
                            string fbackground = match.fetch_named ("color");
                            this.background = fbackground;
                        } else if (match.fetch_named ("id") == "f_high") {
                            string ff_high = match.fetch_named ("color");
                            this.f_high = ff_high;
                        } else if (match.fetch_named ("id") == "f_med") {
                            string ff_med = match.fetch_named ("color");
                            this.f_med = ff_med;
                        } else if (match.fetch_named ("id") == "f_low") {
                            string ff_low = match.fetch_named ("color");
                            this.f_low = ff_low;
                        } else if (match.fetch_named ("id") == "f_inv") {
                            string ff_inv = match.fetch_named ("color");
                            this.f_inv = ff_inv;
                        } else if (match.fetch_named ("id") == "b_high") {
                            string fb_high = match.fetch_named ("color");
                            this.b_high = fb_high;
                        } else if (match.fetch_named ("id") == "b_med") {
                            string fb_med = match.fetch_named ("color");
                            this.b_med = fb_med;
                        } else if (match.fetch_named ("id") == "b_low") {
                            string fb_low = match.fetch_named ("color");
                            this.b_low = fb_low;
                        } else if (match.fetch_named ("id") == "b_inv") {
                            string fb_inv = match.fetch_named ("color");
                            this.b_inv = fb_inv;
                        }
                    } while (match.next ());
                    string css_light = """
                        @define-color colorPrimary %s;
                        @define-color colorSecondary %s;
                        @define-color colorAccent %s;
                        @define-color windowPrimary %s;
                        @define-color textColorPrimary %s;
                        @define-color textColorSecondary %s;

                        .dm-window {
                            background: @colorPrimary;
                            color: @textColorPrimary;
                        }

                        .dm-toolbar {
                            background: @colorPrimary;
                            color: @windowPrimary;
                            box-shadow: 0 1px transparent inset;
                        }

                        .dm-actionbar {
                            background: @colorPrimary;
                            box-shadow: 0 1px transparent inset;
                            color: @textColorSecondary;
                            padding: 8px;
                            border-top: 1px solid alpha (@textColorPrimary, 0);
                        }

                        .dm-actionbar image {
                            color: @textColorSecondary;
                        }

                        .dm-actionbar button:hover {
                            background: @colorSecondary;
                        }

                        .dm-actionbar button:active {
                            background: @colorAccent;
                        }

                        .dm-reverse image {
                            -gtk-icon-transform: rotate(180deg);
                        }

                        .dm-grid {
                            background: @colorPrimary;
                        }

                        .dm-text {
                            font-family: 'Cousine', Courier, monospace;
                            font-size: 1.66em;
                        }

                        .dm-clrbtn {
                            background: @colorPrimary;
                            color: @textColorPrimary;
                            box-shadow: 0 1px transparent inset;
                            border: none;
                        }

                        .dm-clrbtn:active {
                            background: @colorAccent;
                        }

                        .dm-clrbtn colorswatch {
                            border-radius: 8px;
                        }
                    """.printf(this.background, this.b_inv, this.b_med, this.b_high, this.b_high, this.b_med);

                    try {
                        var provider = new Gtk.CssProvider ();
                        provider.load_from_data (css_light, -1);
                        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),provider,Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
                    } catch {}

                    grid.line_color.parse (this.f_high);
			        grid.grid_dot_color.parse (this.f_med);
			        grid.background_color.parse (this.background);
			        grid.line_color_button.rgba = grid.line_color;

                    print ("Setupped colors from file.\n");
                }
            } catch (Error error) {
                print (@"SVG File error: $(error.message)\n");
            }
        }

#if VALA_0_42
        protected bool match_keycode (uint keyval, uint code) {
#else
        protected bool match_keycode (int keyval, uint code) {
#endif
            Gdk.KeymapKey [] keys;
            Gdk.Keymap keymap = Gdk.Keymap.get_for_display (Gdk.Display.get_default ());
            if (keymap.get_entries_for_keyval (keyval, out keys)) {
                foreach (var key in keys) {
                    if (code == key.keycode)
                        return true;
                    }
                }

            return false;
        }

        public override bool delete_event (Gdk.EventAny event) {
            int x, y;
            get_position (out x, out y);

            var settings = AppSettings.get_default ();
            settings.window_x = x;
            settings.window_y = y;
            return false;
        }
    }
}
