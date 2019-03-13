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
        public string f_inv = "#333333";
        public string f_low = "#444444";
        public string b_med = "#72DEC1";
        public string bg = "#EEEEEE";
        public string b_inv = "#FFB545";
        public string b_low = "#CCCCCC";

        public MainWindow (Gtk.Application application) {
            GLib.Object (
                application: application,
                icon_name: "com.github.lainsce.dot-matrix",
                height_request: 780,
                width_request: 810,
                title: (_("Dot Matrix"))
            );
            var settings = AppSettings.get_default ();

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

            string css_light = """
                @define-color colorAccent %s;
                @define-color colorPrimary %s;
                @define-color colorSecondary %s;
                @define-color textColorPrimary %s;
                @define-color textColorSecondary %s;

                .dm-window {
                    background: @colorPrimary;
                    color: @textColorPrimary;
                }

                .dm-toolbar {
                    background: @colorPrimary;
                    color: @textColorPrimary;
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
            """.printf(this.b_med, this.bg, this.b_inv, this.f_inv, this.f_low);

            string css_dark = """
                @define-color colorAccent %s;
                @define-color colorPrimary %s;
                @define-color colorSecondary %s;
                @define-color textColorPrimary %s;
                @define-color textColorSecondary %s;

                .dm-window {
                    background: @colorPrimary;
                    color: @textColorPrimary;
                }

                .dm-toolbar {
                    background: @colorPrimary;
                    color: @textColorPrimary;
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
                
                .dm-actionbar image:hover {
                    color: @colorPrimary;
                }
                
                .dm-actionbar image:active {
                    color: @colorPrimary;
                }

                .dm-actionbar button:hover {
                    background: @colorAccent;
                }

                .dm-actionbar button:active {
                    background: @colorSecondary;
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
            """.printf(this.b_med, this.f_inv, this.b_inv, this.bg, this.b_low);
            try {
                if (settings.prefer_light == true) {
                    var provider = new Gtk.CssProvider ();
                    provider.load_from_data (css_light, -1);
                    Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                      provider,
                                                      Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
                } else if (settings.prefer_light == false) {
                    var provider2 = new Gtk.CssProvider ();
                    provider2.load_from_data (css_dark, -1);
                    Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                      provider2,
                                                      Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
                }
            } catch {}


            settings.changed.connect (() => {
                try {
                    if (settings.prefer_light == true) {
                        var provider = new Gtk.CssProvider ();
                        provider.load_from_data (css_light, -1);
                        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                          provider,
                                                          Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
                    } else if (settings.prefer_light == false) {
                        var provider2 = new Gtk.CssProvider ();
                        provider2.load_from_data (css_dark, -1);
                        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                          provider2,
                                                          Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
                    }
                } catch {}
            });
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

            mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
            mode_switch.primary_icon_tooltip_text = ("Light background");
            mode_switch.secondary_icon_tooltip_text = ("Dark background");
            mode_switch.valign = Gtk.Align.CENTER;

            if (settings.prefer_light == true) {
                mode_switch.active = false;
            } else if (settings.prefer_light == false) {
                mode_switch.active = true;
            }

            mode_switch.notify["active"].connect (() => {
                if (mode_switch.active) {
                    debug ("Get dark!");
                    settings.prefer_light = false;
                } else {
                    debug ("Get light!");
                    settings.prefer_light = true;
                }
            });
            titlebar.pack_end (mode_switch);

            var scrolled = new Gtk.ScrolledWindow (null, null);
            grid = new Widgets.UI (this);
            scrolled.add (grid);
            scrolled.expand = true;

            actionbar = new Gtk.ActionBar ();
			actionbar.get_style_context ().add_class ("dm-actionbar");

            var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.expand = true;
            grid.attach (scrolled, 1, 0, 1, 1);
            grid.show_all ();
            this.add (grid);
            this.show_all ();
        }

        public void get_colors_from_svg () {
            // TODO: This method;
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
