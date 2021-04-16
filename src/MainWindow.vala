/*
* Copyright (c) 2021 Lains
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
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
    [GtkTemplate (ui = "/io/github/lainsce/DotMatrix/mainwindow.ui")]
    public class MainWindow : Hdy.ApplicationWindow {
        delegate void HookFunc ();
        public Widgets.UI ui;

        [GtkChild]
        public Gtk.Button new_button;
        [GtkChild]
        public Gtk.Button save_button;
        [GtkChild]
        public Gtk.Button undo_button;
        [GtkChild]
        public Gtk.MenuButton menu_button;
        [GtkChild]
        public Gtk.Box dabox;
        [GtkChild]
        public Gtk.ColorButton line_color_button;
        [GtkChild]
        public Gtk.SpinButton line_thickness_button;
        [GtkChild]
        public Gtk.Button line_curve_button;
        [GtkChild]
        public Gtk.Button line_curve_reverse_button;
        [GtkChild]
        public Gtk.Button line_straight_button;

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

        public SimpleActionGroup actions { get; construct; }
        public const string ACTION_PREFIX = "win.";
        public const string ACTION_ABOUT = "action_about";
        public const string ACTION_KEYS = "action_keys";
        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        private const GLib.ActionEntry[] ACTION_ENTRIES = {
              {ACTION_ABOUT, action_about },
              {ACTION_KEYS, action_keys},
        };

        public Gtk.Application app { get; construct; }
        public MainWindow (Gtk.Application application) {
            GLib.Object (
                application: application,
                app: application,
                icon_name: Config.APP_ID
            );

            key_press_event.connect ((e) => {
                uint keycode = e.hardware_keycode;

                if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                    if (match_keycode (Gdk.Key.q, keycode)) {
                        this.destroy ();
                    }

                    if (match_keycode (Gdk.Key.z, keycode)) {
                        ui.undo ();
                        ui.current_path = new Path ();
				        ui.da.queue_draw ();
                    }

                    if (match_keycode (Gdk.Key.x, keycode)) {
                        ui.line_thickness -= 5;
                        line_thickness_button.set_value (ui.line_thickness);
                        ui.da.queue_draw ();
                    }

                    if ((e.state & Gdk.ModifierType.SHIFT_MASK) != 0) {
                        if (match_keycode (Gdk.Key.x, keycode)) {
                            ui.line_thickness += 5;
                            line_thickness_button.set_value (ui.line_thickness);
                            ui.da.queue_draw ();
                        }
                    }
                }
                return false;
            });
        }

        construct {
            // Initial settings
            Hdy.init ();

            int x = DotMatrix.Application.gsettings.get_int ("window-w");
            int y = DotMatrix.Application.gsettings.get_int ("window-h");
            if (x != -1 && y != -1) {
                this.resize (x, y);
            }

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/io/github/lainsce/DotMatrix/app.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
            default_theme.add_resource_path ("/io/github/lainsce/DotMatrix");

            Gtk.StyleContext style = get_style_context ();
            if (Config.PROFILE == "Devel") {
                style.add_class ("devel");
            }

            // Actions
            actions = new SimpleActionGroup ();
            actions.add_action_entries (ACTION_ENTRIES, this);
            insert_action_group ("win", actions);

            foreach (var action in action_accelerators.get_keys ()) {
                var accels_array = action_accelerators[action].to_array ();
                accels_array += null;

                app.set_accels_for_action (ACTION_PREFIX + action, accels_array);
            }

            // UI
            new_button.clicked.connect ((e) => {
                ui.clear ();
            });

			save_button.clicked.connect ((e) => {
				try {
					ui.save ();
				} catch (Error e) {
					warning ("Unexpected error during save: " + e.message);
				}
            });

			undo_button.clicked.connect ((e) => {
				ui.undo ();
				ui.current_path = new Path ();
				ui.da.queue_draw ();
			});

			var builder = new Gtk.Builder.from_resource ("/io/github/lainsce/DotMatrix/menu.ui");
            menu_button.menu_model = (MenuModel)builder.get_object ("menu");

            ui = new Widgets.UI (this);
            ui.line_color.parse (this.f_high);
            ui.grid_main_dot_color.parse (this.b_med);
			ui.grid_dot_color.parse (this.b_low);
			ui.background_color.parse (this.background);

			line_color_button.color_set.connect ((e) => {
				ui.current_path.color = line_color_button.rgba;
				ui.da.queue_draw ();
			});

			line_thickness_button.value_changed.connect ((e) => {
                ui.line_thickness = line_thickness_button.get_value ();
			});

			line_curve_button.clicked.connect ((e) => {
				ui.paths.append (ui.current_path);
				ui.current_path.is_curve = true;
				ui.current_path.is_reverse_curve = false;
				ui.current_path = new Path ();
				ui.da.queue_draw ();
			});

			line_curve_reverse_button.clicked.connect ((e) => {
				ui.paths.append (ui.current_path);
				ui.current_path.is_curve = true;
				ui.current_path.is_reverse_curve = true;
				ui.current_path = new Path ();
				ui.da.queue_draw ();
			});

			line_straight_button.clicked.connect ((e) => {
				ui.paths.append (ui.current_path);
				ui.current_path.is_curve = false;
				ui.current_path = new Path ();
				ui.da.queue_draw ();
            });

			line_color_button.rgba = ui.line_color;

            dabox.add (ui);
            dabox.show_all ();

            this.set_size_request (360, 240);
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
            int x, y;
            get_size (out x, out y);

            DotMatrix.Application.gsettings.set_int ("window-w", x);
            DotMatrix.Application.gsettings.set_int ("window-h", y);

            if (ui.dirty) {
                ui.clear ();
            }

            return false;
        }

        public void action_about () {
            const string COPYRIGHT = "Copyright \xc2\xa9 2019-2021 Paulo \"Lains\" Galardi\n";

            const string? AUTHORS[] = {
                "Paulo \"Lains\" Galardi",
                null
            };

            var program_name = Config.NAME_PREFIX + _("Dot Matrix");
            Gtk.show_about_dialog (this,
                                   "program-name", program_name,
                                   "logo-icon-name", Config.APP_ID,
                                   "version", Config.VERSION,
                                   "comments", _("The glyph playground of creativity from simple lines."),
                                   "copyright", COPYRIGHT,
                                   "authors", AUTHORS,
                                   "artists", null,
                                   "license-type", Gtk.License.GPL_3_0,
                                   "wrap-license", false,
                                   "translator-credits", _("translator-credits"),
                                   null);
        }

        public void action_keys () {
            try {
                var build = new Gtk.Builder ();
                build.add_from_resource ("/io/github/lainsce/DotMatrix/shortcuts.ui");
                var window = (Gtk.ShortcutsWindow) build.get_object ("shortcuts-dotmatrix");
                window.set_transient_for (this);
                window.show_all ();
            } catch (Error e) {
                warning ("Failed to open shortcuts window: %s\n", e.message);
            }
        }
    }
}
