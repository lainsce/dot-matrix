/*
* Copyright (c) 2018 Lains
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
        public MainWindow (Gtk.Application application) {
            GLib.Object (
                application: application,
                icon_name: "com.github.lainsce.dot-matrix",
                height_request: 825,
                width_request: 900,
                title: (_("Dot Matrix"))
            );

            key_press_event.connect ((e) => {
                uint keycode = e.hardware_keycode;

                if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                    if (match_keycode (Gdk.Key.q, keycode)) {
                        this.destroy ();
                    }
                }
                return false;
            });
        }

        construct {
            var settings = AppSettings.get_default ();
            int x = settings.window_x;
            int y = settings.window_y;
            int h = settings.window_height;
            int w = settings.window_width;
            if (x != -1 && y != -1) {
                this.move (x, y);
            }
            if (w != 0 && h != 0) {
                this.resize (w, h);
            }

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/lainsce/dot-matrix/stylesheet.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                      provider,
                                                      Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            this.get_style_context ().add_class ("rounded");

            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
            default_theme.add_resource_path ("/com/github/lainsce/dot-matrix");

            var titlebar = new Gtk.HeaderBar ();
            titlebar.show_close_button = true;
            var titlebar_style_context = titlebar.get_style_context ();
            titlebar_style_context.add_class (Gtk.STYLE_CLASS_FLAT);
            titlebar_style_context.add_class ("dm-toolbar");
            this.set_titlebar (titlebar);

            var scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled.expand = true;
            var actionbar = new Widgets.StatusBar ();
            actionbar.reveal_child = true;
            actionbar.hexpand = true;

            var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.expand = true;
            grid.attach (scrolled, 0, 0, 1, 1);
            grid.attach (actionbar, 0, 1, 1, 1);
            grid.show_all ();
            this.add (grid);
            this.show_all ();
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
            int x, y, w, h;
            get_position (out x, out y);
            get_size (out w, out h);

            var settings = AppSettings.get_default ();
            settings.window_x = x;
            settings.window_y = y;
            settings.window_width = w;
            settings.window_height = h;
            return false;
        }
    }
}
