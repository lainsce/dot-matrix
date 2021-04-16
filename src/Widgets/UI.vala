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

    public class Widgets.UI : Gtk.Bin {
        public MainWindow window;
        public Gtk.DrawingArea da;

        public GLib.List<Path> paths = new GLib.List<Path> ();
		public Path current_path = new Path ();

		private int ratio = 25;
		public double line_thickness = 5;
		public EditableLabel line_thickness_label;
		public Gdk.RGBA grid_main_dot_color;
        public Gdk.RGBA grid_dot_color;
		public Gdk.RGBA background_color;
		public Gdk.RGBA line_color;
		public Gtk.ColorButton line_color_button;
		public bool dirty {get; set;}
		private bool see_grid {get; set; default=true;}
		private bool inside {get; set; default=false;}
        private double cur_x;
		private double cur_y;

        public UI (MainWindow win) {
			this.window = win;
            da = new Gtk.DrawingArea ();
			da.expand = true;
			da.set_size_request(this.get_allocated_width(),this.get_allocated_height());

			da.add_events (Gdk.EventMask.BUTTON_PRESS_MASK);
			da.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK);
			da.add_events (Gdk.EventMask.LEAVE_NOTIFY_MASK);
			da.add_events (Gdk.EventMask.POINTER_MOTION_MASK);

			da.enter_notify_event.connect(mouse_entered);
            da.leave_notify_event.connect(mouse_left);

			da.button_press_event.connect ((e) => {
				int h = da.get_allocated_height ();
			    int w = da.get_allocated_width ();

				var x = (int) Math.round(e.x.clamp (0, (double)(w)) / ratio) * ratio;
				var y = (int) Math.round(e.y.clamp (0, (double)(h)) / ratio) * ratio;
				current_path.points.append (new Point (x, y));
				dirty = true;
				da.queue_draw ();
				return false;
			});

			da.motion_notify_event.connect ((e) => {
				int h = da.get_allocated_height ();
			    int w = da.get_allocated_width ();

				cur_x = (int) Math.round(e.x.clamp (0, (double)(w)) / ratio) * ratio;
				cur_y = (int) Math.round(e.y.clamp (0, (double)(h)) / ratio) * ratio;
				return false;
			});

			da.draw.connect ((c) => {
                c.set_antialias (Cairo.Antialias.SUBPIXEL);
				draw_grid (c);
				find_mouse (c);
				draws (c);

				return false;
			});

            this.add (da);
		}

		// Drawing Section
		public void draw_circle(Cairo.Context c, double x, double y) {
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
		public bool mouse_entered(Gdk.EventCrossing e) {
			cur_x = e.x;
			cur_y = e.y;
			inside = true;
			queue_draw();
			return true;
		}
		public bool mouse_left(Gdk.EventCrossing e) {
			cur_x = -300;
			cur_y = -300;
			inside = false;
			queue_draw();
			return true;
		}
		private void find_mouse(Cairo.Context c) {
			int h = da.get_allocated_height ();
			int w = da.get_allocated_width ();
			if ((cur_x <= ((h * ratio) + ratio) && (cur_y <= ((w * ratio) + ratio)))) {
				if (inside) {
					draw_circle (c,cur_x,cur_y);
				}
				return;
			}
		}

		private void draw_grid (Cairo.Context c) {
			if (see_grid == true) {
				int i, j;
				int h = da.get_allocated_height ();
				int w = da.get_allocated_width ();
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
			c.set_line_cap (Cairo.LineCap.ROUND);
			c.set_line_join (Cairo.LineJoin.ROUND);
			queue_draw ();
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
				queue_draw ();
			}
		}

		// IO Section
		public void clear () {
            var dialog = new Widgets.Dialog ();
			dialog.transient_for = window;

            dialog.response.connect ((response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.OK:
						debug ("User saves the file.");
						try {
							save ();
						} catch (Error e) {
							warning ("Unexpected error during save: " + e.message);
						}
						paths = null;
						current_path = new Path ();
						queue_draw ();
						dirty = false;
                        dialog.close ();
                        break;
                    case Gtk.ResponseType.NO:
						paths = null;
						current_path = new Path ();
						queue_draw ();
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
                dialog.run ();
            }
        }

		public void save () throws Error {
			debug ("Save as button pressed.");
			var file = display_save_dialog ();

			string path = file.get_path ();

			if (file == null) {
				debug ("User cancelled operation. Aborting.");
			} else {
				var svg = new Cairo.SvgSurface (path + ".svg", da.get_allocated_width(),da.get_allocated_height());
				svg.restrict_to_version (Cairo.SvgVersion.VERSION_1_2);
				Cairo.Context c = new Cairo.Context (svg);
				draws (c);
				svg.finish ();
				file = null;
			}
		}

		public Gtk.FileChooserDialog create_file_chooser (string title,
		Gtk.FileChooserAction action) {
			var chooser = new Gtk.FileChooserDialog (title, null, action);
			chooser.add_button ("_Cancel", Gtk.ResponseType.CANCEL);
			if (action == Gtk.FileChooserAction.OPEN) {
				chooser.add_button ("_Open", Gtk.ResponseType.ACCEPT);
			} else if (action == Gtk.FileChooserAction.SAVE) {
				chooser.add_button ("_Save", Gtk.ResponseType.ACCEPT);
				chooser.set_do_overwrite_confirmation (true);
			}
			var filter1 = new Gtk.FileFilter ();
			filter1.set_filter_name (_("SVG files"));
			filter1.add_pattern ("*.svg");
			chooser.add_filter (filter1);

			var filter = new Gtk.FileFilter ();
			filter.set_filter_name (_("All files"));
			filter.add_pattern ("*");
			chooser.add_filter (filter);
			return chooser;
		}

		public File display_save_dialog () {
			var chooser = create_file_chooser (_("Save file"),
					Gtk.FileChooserAction.SAVE);
			File file = null;
			if (chooser.run () == Gtk.ResponseType.ACCEPT)
				file = chooser.get_file ();
			chooser.destroy();
			return file;
		}
    }
}
