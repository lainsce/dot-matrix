/*
* Copyright (c) 2021-2022 Lains
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
    public class Point : Object {
		public double x;
		public double y;
		public Point (double x, double y) {
			this.x = x;
			this.y = y;
		}
	}
	public class Path : Object {
		public bool is_curve {get; set;}
		public bool is_reverse_curve {get; set;}
		public Gdk.RGBA color;
		public GLib.List<Point> points = null;
	}

    public class Widgets.UI : Object {
        private bool inside {get; set; default=false;}
		private bool see_grid {get; set; default=true;}
        private double cur_x = 20;
		private double cur_y = 20;
		private int ratio = 20;

        public MainWindow window;
        public GLib.List<Path> current_paths = new GLib.List<Path> ();
        public GLib.List<Path> history_paths = new GLib.List<Path> ();
		public Path current_path = new Path ();
		public bool dirty {get; set;}
		public Gdk.RGBA background_color;
        public Gdk.RGBA grid_dot_color;
		public Gdk.RGBA grid_main_dot_color;
		public Gdk.RGBA line_color;
		public Gtk.ColorButton line_color_button;
		public Gtk.DrawingArea da;

        public UI (MainWindow win, Gtk.DrawingArea da) {
			this.window = win;
			this.da = da;
			var settings = new Settings ();
			da.set_size_request(settings.canvas_width,settings.canvas_height);
			da.set_content_height (settings.canvas_height+40);
			da.set_content_width (settings.canvas_width+40);

			var evconmo = new Gtk.EventControllerMotion ();
			da.add_controller (evconmo);

            evconmo.leave.connect((e) => {
                cur_x = -999;
		        cur_y = -999;
		        inside = false;
		        da.queue_draw();
            });
            evconmo.motion.connect ((e, x, y) => {
				int h = settings.canvas_height + 10;
				int w = settings.canvas_width + 10;
			    inside = true;
			    da.queue_draw();

				cur_x = Math.round(x.clamp (ratio, (double)(w)) / ratio) * ratio;
				cur_y = Math.round(y.clamp (ratio, (double)(h)) / ratio) * ratio;
			});

			var drag = new Gtk.GestureDrag ();
			da.add_controller (drag);

            // Disable drag because it goes against the app's idea of interaction.
			drag.drag_begin.connect ((x, y) => {
			    drag.set_state (Gtk.EventSequenceState.DENIED);
                return;
			});
			drag.drag_end.connect ((x, y) => {
			    drag.set_state (Gtk.EventSequenceState.DENIED);
                return;
			});
			drag.drag_update.connect ((x, y) => {
			    drag.set_state (Gtk.EventSequenceState.DENIED);
                return;
			});

			var press = new Gtk.GestureClick ();
			da.add_controller (press);
            press.button = Gdk.BUTTON_PRIMARY;

            press.released.connect ((gesture, n_press, x, y) => {
                if (n_press > 1) {
                    press.set_state (Gtk.EventSequenceState.DENIED);
                    return;
                }

				int h = settings.canvas_height + 10;
				int w = settings.canvas_width + 10;

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
			draws (c);
			find_mouse (c);
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
		}
		private void find_mouse(Cairo.Context c) {
			draw_circle (c, cur_x, cur_y);
		}

		private void draw_grid (Cairo.Context c) {
			if (see_grid == true) {
				int i, j;
				var settings = new Settings ();
				int h = settings.canvas_height;
				int w = settings.canvas_width;
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
			var settings = new Settings ();
			c.set_line_width (settings.thickness);
			c.set_fill_rule (Cairo.FillRule.EVEN_ODD);

			if (current_path != null) {
				c.set_source_rgba (grid_dot_color.red, grid_dot_color.green, grid_dot_color.blue, 0.5);
				draw_guideline (c, current_path);
			}
			c.stroke ();

			foreach (var path in current_paths) {
			    current_path.color = window.line_color_button.rgba;
				if (path.is_curve == true) {
					if (path.is_reverse_curve == true) {
						if (settings.close_paths == true) {
						    draw_reverse_curve (c, path);
							c.close_path ();
							c.fill ();
							c.stroke ();
							draw_reverse_curve (c, path);
							c.stroke ();
							dirty = true;
						} else if (settings.close_paths == false) {
							draw_reverse_curve (c, path);
							c.stroke ();
							dirty = true;
						}
					} else if (path.is_reverse_curve == false) {
						if (settings.close_paths == true) {
						    draw_curve (c, path);
							c.close_path ();
							c.fill ();
							c.stroke ();
							draw_curve (c, path);
							c.stroke ();
							dirty = true;
						} else if (settings.close_paths == false) {
						    draw_curve (c, path);
							c.stroke ();
							dirty = true;
						}
					}
				} else if (path.is_curve == false) {
					if (settings.close_paths == true) {
					    draw_path (c, path);
						c.close_path ();
						c.fill ();
						c.stroke ();
						draw_path (c, path);
						c.stroke ();
						dirty = true;
					} else if (settings.close_paths == false) {
					    draw_path (c, path);
						c.stroke ();
						dirty = true;
					}
				}
			}

			da.queue_draw ();
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
			if (current_paths != null) {
				unowned List<Path> last = current_paths.last ();
				if (current_path != null) {
					if (last.prev != null) {
						current_path = last.prev.data;
					} else {
						window.undo_button.sensitive = false;
					}
				}
				window.redo_button.sensitive = true;
				history_paths.append (last.data);
				current_paths.delete_link (last);
				da.queue_draw ();
			}
		}

		public void redo () {
		    if (history_paths != null) {
	            unowned List<Path> h_last = history_paths.last ();
	            unowned List<Path> last = current_paths.last ();
	            if (current_path != null) {
		            if (last != null) {
			            current_path = last.data;
			            if (last.next == null) {
		                    window.redo_button.sensitive = false;
		                }
		            }
	            }
	            window.undo_button.sensitive = true;
	            current_paths.append (h_last.data);
	            history_paths.delete_link (h_last);
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

            var no_button = dialog.add_button (_("Don't Save"), Gtk.ResponseType.NO);
            no_button.get_style_context ().add_class ("destructive-action");
            dialog.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
            dialog.add_button (_("Save"), Gtk.ResponseType.OK);

            dialog.response.connect ((response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.OK:
						debug ("User saves the file.");
						save.begin ();
						current_paths = null;
						history_paths = null;
						current_path = new Path ();
						current_path.color = window.line_color_button.rgba;
						window.undo_button.sensitive = false;
						window.redo_button.sensitive = false;
						da.queue_draw ();
						dirty = false;
                        dialog.close ();
                        break;
                    case Gtk.ResponseType.NO:
						current_paths = null;
						history_paths = null;
						current_path = new Path ();
						current_path.color = window.line_color_button.rgba;
						window.undo_button.sensitive = false;
						window.redo_button.sensitive = false;
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
				var svg = new Cairo.SvgSurface (path, da.content_width, da.content_height);
				svg.restrict_to_version (Cairo.SvgVersion.VERSION_1_2);
				svg.set_document_unit (Cairo.SvgUnit.PX);
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

