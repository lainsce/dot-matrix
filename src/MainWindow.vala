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
    public class MainWindow : Adw.ApplicationWindow {
        delegate void HookFunc ();
        public Widgets.UI ui;

        [GtkChild]
        public unowned Gtk.Button new_button;
        [GtkChild]
        public unowned Gtk.Button save_button;
        [GtkChild]
        public unowned Gtk.Button undo_button;
        [GtkChild]
        public unowned Gtk.Button redo_button;
        [GtkChild]
        public unowned Gtk.MenuButton menu_button;
        [GtkChild]
        public unowned Gtk.DrawingArea da;
        [GtkChild]
        public unowned Gtk.ColorButton line_color_button;
        [GtkChild]
        public unowned Gtk.SpinButton line_thickness_button;
        [GtkChild]
        public unowned Gtk.Button line_curve_button;
        [GtkChild]
        public unowned Gtk.Button line_curve_reverse_button;
        [GtkChild]
        public unowned Gtk.Button line_straight_button;
        [GtkChild]
        public unowned Gtk.ToggleButton close_path_button;

        // Global Color Palette
        public string background = "#E8F1EE";
        public string f_high = "#191C1B";
        public string b_med = "#898C8B";
        public string b_low = "#A9ACAB";

        public SimpleActionGroup actions { get; construct; }
        public const string ACTION_PREFIX = "win.";
        public const string ACTION_ABOUT = "action_about";
        public const string ACTION_KEYS = "action_keys";
        public const string ACTION_UNDO = "action_undo";
        public const string ACTION_REDO = "action_redo";
        public const string ACTION_PREFS = "action_prefs";
        public const string ACTION_INC_LINE = "action_inc_line";
        public const string ACTION_DEC_LINE = "action_dec_line";
        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        private const GLib.ActionEntry[] ACTION_ENTRIES = {
              {ACTION_ABOUT, action_about},
              {ACTION_KEYS, action_keys},
              {ACTION_UNDO, action_undo},
              {ACTION_REDO, action_redo},
              {ACTION_PREFS, action_prefs},
              {ACTION_INC_LINE, action_inc_line},
              {ACTION_DEC_LINE, action_dec_line},
        };

        public Adw.Application app { get; construct; }
        public MainWindow (Adw.Application application) {
            GLib.Object (
                application: application,
                app: application,
                icon_name: Config.APP_ID
            );

            var evconkey = new Gtk.ShortcutController ();
            this.add_controller (evconkey);


        }

        construct {
            // Initial settings
            var theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            theme.add_resource_path ("/io/github/lainsce/DotMatrix");

            if (Config.DEVELOPMENT)
                add_css_class ("devel");

            // Actions
            actions = new SimpleActionGroup ();
            actions.add_action_entries (ACTION_ENTRIES, this);
            insert_action_group ("win", actions);

            foreach (var action in action_accelerators.get_keys ()) {
                var accels_array = action_accelerators[action].to_array ();
                accels_array += null;

                app.set_accels_for_action (ACTION_PREFIX + action, accels_array);
            }
            app.set_accels_for_action("app.quit", {"<Ctrl>q"});
            app.set_accels_for_action ("win.action_keys", {"<Ctrl>question"});
            app.set_accels_for_action ("win.action_prefs", {"<Ctrl>comma"});
            app.set_accels_for_action ("win.action_undo", {"<Ctrl>z"});
            app.set_accels_for_action ("win.action_redo", {"<Ctrl><Shift>z"});
            app.set_accels_for_action ("win.action_inc_line", {"<Ctrl>x"});
            app.set_accels_for_action ("win.action_dec_line", {"<Ctrl><Shift>x"});

            // UI
            ui = new Widgets.UI (this, da);
            ui.line_color.parse (this.f_high);
            ui.grid_main_dot_color.parse (this.b_med);
			ui.grid_dot_color.parse (this.b_low);
			ui.background_color.parse (this.background);
			ui.current_path.color = ui.line_color;

			new_button.clicked.connect ((e) => {
                ui.clear ();
            });
			save_button.clicked.connect ((e) => {
				try {
					ui.save.begin ();
				} catch (Error e) {
					warning ("Unexpected error during save: " + e.message);
				}
            });

			undo_button.clicked.connect ((e) => {
				ui.undo ();
				ui.current_path = new Path ();
				ui.current_path.color = ui.line_color;
				ui.da.queue_draw ();
			});
			redo_button.clicked.connect ((e) => {
				ui.redo ();
				ui.current_path = new Path ();
				ui.current_path.color = ui.line_color;
				ui.da.queue_draw ();
			});

            line_color_button.rgba = ui.line_color;
			line_color_button.color_set.connect ((e) => {
				ui.current_path.color = line_color_button.rgba;
				ui.da.queue_draw ();
			});

			line_thickness_button.value_changed.connect ((e) => {
                ui.line_thickness = line_thickness_button.get_value ();
                ui.da.queue_draw ();
			});

			line_curve_button.clicked.connect ((e) => {
				ui.current_paths.append (ui.current_path);
				ui.history_paths.append (ui.current_path);
				undo_button.sensitive = true;
				ui.current_path.is_curve = true;
				ui.current_path.is_reverse_curve = false;
				ui.current_path = new Path ();
				ui.current_path.color = ui.line_color;
				ui.da.queue_draw ();
				ui.dirty = true;
			});

			line_curve_reverse_button.clicked.connect ((e) => {
				ui.current_paths.append (ui.current_path);
				ui.history_paths.append (ui.current_path);
				undo_button.sensitive = true;
				ui.current_path.is_curve = true;
				ui.current_path.is_reverse_curve = true;
				ui.current_path = new Path ();
				ui.current_path.color = ui.line_color;
				ui.da.queue_draw ();
				ui.dirty = true;
			});

			line_straight_button.clicked.connect ((e) => {
				ui.current_paths.append (ui.current_path);
				ui.history_paths.append (ui.current_path);
				undo_button.sensitive = true;
				ui.current_path.is_curve = false;
				ui.current_path = new Path ();
				ui.current_path.color = ui.line_color;
				ui.da.queue_draw ();
				ui.dirty = true;
            });

			close_path_button.toggled.connect ((e) => {
				ui.current_paths.append (ui.current_path);
				ui.history_paths.append (ui.current_path);
				undo_button.sensitive = true;
				if (ui.is_closed == true) {
					ui.is_closed = false;
				} else if (ui.is_closed == false) {
					ui.is_closed = true;
				}
				ui.current_path = new Path ();
				ui.current_path.color = ui.line_color;
				ui.da.queue_draw ();
				ui.dirty = true;
            });

            this.set_size_request (360, 360); // shows an uniformed grid of dots at first launch
            this.show ();
        }

        protected override bool close_request () {
            if (ui.dirty = true) {
                ui.clear ();
            }

            this.dispose ();
            return false;
        }

        public void action_about () {
            const string COPYRIGHT = "Copyright \xc2\xa9 2019-2021 Paulo \"Lains\" Galardi\n";

            const string? AUTHORS[] = {
                "Paulo \"Lains\" Galardi",
                null
            };

            var program_name = "Dot Matrix" + Config.NAME_SUFFIX;
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
                                   // TRANSLATORS: 'Name <email@domain.com>' or 'Name https://website.example'
                                   "translator-credits", _("translator-credits"),
                                   null);
        }

        public void action_keys () {
            try {
                var build = new Gtk.Builder ();
                build.add_from_resource ("/io/github/lainsce/DotMatrix/shortcuts.ui");
                var window = (Gtk.ShortcutsWindow) build.get_object ("shortcuts-dotmatrix");
                window.set_transient_for (this);
                window.show ();
            } catch (Error e) {
                warning ("Failed to open shortcuts window: %s\n", e.message);
            }
        }
        public void action_prefs () {
            var prefs = new Prefs ();
            prefs.set_transient_for (this);
            prefs.show ();
            var settings = new Settings ();
            prefs.width = settings.canvas_width;
            prefs.height = settings.canvas_height;
        }

        public void action_undo () {
            ui.undo ();
			ui.current_path = new Path ();
			ui.current_path.color = ui.line_color;
			ui.da.queue_draw ();
        }
        public void action_redo () {
            ui.redo ();
			ui.current_path = new Path ();
			ui.current_path.color = ui.line_color;
			ui.da.queue_draw ();
        }
        public void action_inc_line () {
            ui.line_thickness += 5;
            line_thickness_button.set_value (ui.line_thickness);
            ui.da.queue_draw ();
        }
        public void action_dec_line () {
            ui.line_thickness -= 5;
            line_thickness_button.set_value (ui.line_thickness);
            ui.da.queue_draw ();
        }
    }
}
