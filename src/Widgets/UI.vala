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
    public class Point {
		public double x;
		public double y;
		public Point (double x, double y) {
			this.x = x;
			this.y = y;
		}
	}
	public class Path {
		public GLib.List<Point> points = null;
		public bool is_curve {get; set;}
		public bool is_reverse_curve {get; set;}
		public Gdk.RGBA color;
	}

    public class Widgets.UI {
        public MainWindow window;

        public GLib.List<Path> paths = new GLib.List<Path> ();
		public Path current_path = new Path ();

		private int ratio = 25;
		public double line_thickness = 5;
		public Gdk.RGBA grid_main_dot_color;
        public Gdk.RGBA grid_dot_color;
		public Gdk.RGBA background_color;
		public Gdk.RGBA line_color;
		public Gtk.ColorButton line_color_button;
		public Gtk.DrawingArea da;
		public bool dirty {get; set;}
		private bool see_grid {get; set; default=true;}
		private bool inside {get; set; default=false;}
        private double cur_x;
		private double cur_y;

        public UI (MainWindow win, Gtk.DrawingArea da) {
			this.window = win;
			this.da = da;
			da.set_size_request(win.get_allocated_width(),win.get_allocated_height());

			var evconmo = new Gtk.EventControllerMotion ();
			da.add_controller (evconmo);

            evconmo.leave.connect((e) => {
                cur_x = -999;
		        cur_y = -999;
		        inside = false;
		        da.queue_draw();
            });
            evconmo.motion.connect ((e, x, y) => {
				int h = da.get_allocated_height ();
			    int w = da.get_allocated_width ();
			    inside = true;
			    da.queue_draw();

				cur_x = Math.round(x.clamp (ratio, (double)(w)) / ratio) * ratio;
				cur_y = Math.round(y.clamp (ratio, (double)(h)) / ratio) * ratio;
			});

			var press = new Gtk.GestureClick ();
			da.add_controller (press);
            press.button = Gdk.BUTTON_PRIMARY;

            press.pressed.connect ((gesture, n_press, x, y) => {
                if (n_press > 1) {
                    press.set_state (Gtk.EventSequenceState.DENIED);
                    return;
                }

                int h = da.get_allocated_height ();
			    int w = da.get_allocated_width ();

				var px = (int) Math.round(x.clamp (ratio, (double)(w)) / ratio) * ratio;
				var py = (int) Math.round(y.clamp (ratio, (double)(h)) / ratio) * ratio;

				current_path.points.append (new Point (px, py));
				dirty = true;
				da.queue_draw ();

                press.set_state (Gtk.EventSequenceState.CLAIMED);
            });

			da.set_draw_func (draw_func);
		}

		// Drawing Section
		public void draw_func (Gtk.DrawingArea da, Cairo.Context c, int width, int height) {
			draw_grid (c);
			find_mouse (c);
			draws (c);
		}

		public void draw_circle(Cairo.Context c, double x, double y) {
		    c.set_antialias (Cairo.Antialias.SUBPIXEL);
			c.set_source_rgba (grid_dot_color.red, grid_dot_color.green, grid_dot_color.blue, 1);
			c.arc(x, y, 9, 0, 2.0*3.14);
			c.fill();
			c.set_source_rgba (background_color.red, background_color.green, background_color.blue, background_color.alpha);
			c.arc(x, y, 6, 0, 2.0*3.14);
			c.fill();
			c.set_source_rgba (grid_dot_color.red, grid_dot_color.green, grid_dot_color.blue, 1);
			c.arc(x, y, 3, 0, 2.0*3.14);
			c.fill();
			c.stroke();
		}
		private void find_mouse(Cairo.Context c) {
			draw_circle (c, cur_x, cur_y);
		}

		private void draw_grid (Cairo.Context c) {
			if (see_grid == true) {
				int i, j;
				int h = da.get_allocated_height ();
				int w = da.get_allocated_width ();
				c.set_antialias (Cairo.Antialias.SUBPIXEL);
				c.set_line_width (1);
				for (i = 0; i <= w / ratio; i++) {
					for (j = 0; j <= h / ratio; j++) {
						if (i % 4 == 0 && j % 4 == 0) {
							c.set_source_rgba (grid_main_dot_color.red, grid_main_dot_color.green, grid_main_dot_color.blue, 1);
							c.arc ((i+1)*ratio, (j+1)*ratio, 2.5, 0, 2*Math.PI);
							c.fill ();
						} else {
							c.set_source_rgba (grid_dot_color.red, grid_dot_color.green, grid_dot_color.blue, 1);
							c.arc ((i+1)*ratio, (j+1)*ratio, 1.5, 0, 2*Math.PI);
							c.fill ();
						}
					}
				}
			}
		}

		public void draws (Cairo.Context c) {
		    c.set_antialias (Cairo.Antialias.SUBPIXEL);
			c.set_line_cap (Cairo.LineCap.ROUND);
			c.set_line_join (Cairo.LineJoin.ROUND);
			da.queue_draw ();
			c.set_line_width (line_thickness);
			c.set_fill_rule (Cairo.FillRule.EVEN_ODD);

			if (current_path != null) {
				c.set_source_rgba (grid_dot_color.red, grid_dot_color.green, grid_dot_color.blue, 0.5);
				draw_guideline (c, current_path);
			}
			c.stroke ();

			foreach (var path in paths) {
			    current_path.color = window.line_color_button.rgba;
				if (path.is_curve == true) {
					if (path.is_reverse_curve == true) {
						draw_reverse_curve (c, path);
						c.stroke ();
						dirty = true;
					} else if (path.is_reverse_curve == false) {
						draw_curve (c, path);
						c.stroke ();
						dirty = true;
					}
				} else if (path.is_curve == false) {
					draw_path (c, path);
					c.stroke ();
					dirty = true;
				}
			}
		}

		private void draw_guideline (Cairo.Context c, Path path) {
			if (path.points.length () < 2) {
				return;
			}

			for (int i = 0; i < path.points.length () - 1; i+=1) {
				int start_x = (int) Math.round(path.points.nth_data(i).x / ratio) * ratio;
				int start_y = (int) Math.round(path.points.nth_data(i).y / ratio) * ratio;

				int end_x = (int) Math.round(path.points.nth_data(i+1).x / ratio) * ratio;
				int end_y = (int) Math.round(path.points.nth_data(i+1).y / ratio) * ratio;

				c.move_to (start_x, start_y);
				c.line_to (end_x, end_y);
			}
		}

		private void draw_path (Cairo.Context c, Path path) {
			if (path.points.length () < 2) {
				return;
			}

		    c.set_source_rgba (path.color.red, path.color.green, path.color.blue, 1);

			for (int i = 0; i < path.points.length (); i+=1) {
				int x = (int) Math.round(path.points.nth_data(i).x / ratio) * ratio;
				int y = (int) Math.round(path.points.nth_data(i).y / ratio) * ratio;

				c.line_to (x, y);
			}
		}

		private void draw_curve (Cairo.Context c, Path path) {
			if (path.points.length () < 2) {
				return;
			}

		    c.set_source_rgba (path.color.red, path.color.green, path.color.blue, 1);

			for (int i = 0; i < path.points.length () - 1; i+=1) {
				double start_x = (path.points.nth_data(i).x / ratio) * ratio;
				double start_y = (path.points.nth_data(i).y / ratio) * ratio;

				double end_x = (path.points.nth_data(i+1).x / ratio) * ratio;
				double end_y = (path.points.nth_data(i+1).y / ratio) * ratio;

				c.curve_to (start_x,
				            start_y,
                            2.0 / 3.0 * end_x + 1.0 / 3.0 * end_x,
                            2.0 / 3.0 * start_y + 1.0 / 3.0 * start_y,
                            end_x,
                            end_y);
			}
		}

		private void draw_reverse_curve (Cairo.Context c, Path path) {
			if (path.points.length () < 2) {
				return;
			}

		    c.set_source_rgba (path.color.red, path.color.green, path.color.blue, 1);

			for (int i = 0; i < path.points.length () - 1; i+=1) {
                double start_x = (path.points.nth_data(i).x / ratio) * ratio;
				double start_y = (path.points.nth_data(i).y / ratio) * ratio;

				double end_x = (path.points.nth_data(i+1).x / ratio) * ratio;
				double end_y = (path.points.nth_data(i+1).y / ratio) * ratio;

                c.curve_to (start_x,
                            start_y,
                            2.0 / 3.0 * start_x + 1.0 / 3.0 * start_x,
                            2.0 / 3.0 * end_y + 1.0 / 3.0 * end_y,
                            end_x,
                            end_y);
			}
		}

		public void undo () {
			if (paths != null) {
				unowned List<Path> last = paths.last ();
				unowned List<Path> prev = last.prev;
				paths.delete_link (last);
				if (current_path != null) {
					if (prev != null)
						current_path = prev.data;
					else
						current_path = null;
				}
				da.queue_draw ();
			}
		}

		// IO Section
		public void clear () {
            var flags = Gtk.DialogFlags.DESTROY_WITH_PARENT | Gtk.DialogFlags.MODAL;
            var dialog = new Gtk.MessageDialog (window, flags, Gtk.MessageType.WARNING, Gtk.ButtonsType.NONE, null, null);
            dialog.set_transient_for (window);
            dialog.resizable = false;

            dialog.text = _("Save Image?");
            dialog.secondary_text = _("Not saving means that the image will be lost forever.");

            var ok_button = dialog.add_button (_("Save"), Gtk.ResponseType.OK);
            ok_button.get_style_context ().add_class ("suggested-action");
            var no_button = dialog.add_button (_("Don't Save"), Gtk.ResponseType.NO);
            no_button.get_style_context ().add_class ("destructive-action");
            dialog.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);

            dialog.response.connect ((response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.OK:
						debug ("User saves the file.");
						save.begin ();
						paths = null;
						current_path = new Path ();
						da.queue_draw ();
						dirty = false;
                        dialog.close ();
                        break;
                    case Gtk.ResponseType.NO:
						paths = null;
						current_path = new Path ();
						da.queue_draw ();
                        dialog.close ();
                        break;
                    case Gtk.ResponseType.CANCEL:
                    case Gtk.ResponseType.CLOSE:
                    case Gtk.ResponseType.DELETE_EVENT:
                        dialog.close ();
                        return;
                    default:
                        assert_not_reached ();
                }
            });


            if (dirty) {
                dialog.present ();
            }
        }

		public async void save () throws Error {
			debug ("Save as button pressed.");
            var file = yield display_save_dialog ();

			string path = file.get_path ();

			if (file == null) {
				debug ("User cancelled operation. Aborting.");
			} else {
				var svg = new Cairo.SvgSurface (path, da.get_allocated_width(),da.get_allocated_height());
				svg.restrict_to_version (Cairo.SvgVersion.VERSION_1_2);
				Cairo.Context c = new Cairo.Context (svg);
				draws (c);
				svg.finish ();
				file = null;
			}
		}

		public async File? display_save_dialog () {
            var chooser = new Gtk.FileChooserNative (null, window, Gtk.FileChooserAction.SAVE, null, null);
            chooser.set_transient_for(window);
            chooser.modal = true;

            var filter1 = new Gtk.FileFilter ();
            filter1.set_filter_name (_("SVG files"));
            filter1.add_pattern ("*.svg");
            chooser.add_filter (filter1);
            var filter = new Gtk.FileFilter ();
            filter.set_filter_name (_("All files"));
            filter.add_pattern ("*");
            chooser.add_filter (filter);

            var response = yield run_dialog_async (chooser);

            if (response == Gtk.ResponseType.ACCEPT) {
                return chooser.get_file ();
            }

            return null;
        }

        private async Gtk.ResponseType run_dialog_async (Gtk.FileChooserNative dialog) {
		    var response = Gtk.ResponseType.CANCEL;

		    dialog.response.connect (r => {
			    response = (Gtk.ResponseType) r;

			    run_dialog_async.callback ();
		    });

		    dialog.show ();

		    yield;
		    return response;
	    }
    }
}

