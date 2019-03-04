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
    }

    public class Widgets.UI : Gtk.VBox {
        public MainWindow window;
        public Gtk.DrawingArea da;

        GLib.List<Path> paths = new GLib.List<Path> ();
        Path current_path = null;

		private int ratio = 25;
		private int big_dot = 4;

        public UI () {
            da = new Gtk.DrawingArea ();
            da.expand = true;
			da.set_size_request(this.get_allocated_width(),this.get_allocated_height());

			da.add_events (Gdk.EventMask.BUTTON_PRESS_MASK);

			da.button_press_event.connect ((e) => {
				current_path = new Path ();
				current_path.points.append (new Point (e.x, e.y));
				paths.append (current_path);
				return false;
			});

			da.draw.connect ((c) => {
				int i, j;
				int h = da.get_allocated_height ();
				int w = da.get_allocated_width ();
				for (i = 0; i <= w / ratio; i++) {
					for (j = 0; j <= h / ratio; j++) {
						if ((i - 1) % big_dot == 0 && (j - 1) % big_dot == 0) {
							c.set_source_rgba (0.66, 0.66, 0.66, 1);
							c.arc (i*ratio, j*ratio, 4, 0, 2*Math.PI);
							c.fill ();
						} else {
							c.set_source_rgba (0.8, 0.8, 0.8, 1);
							c.arc (i*ratio, j*ratio, 2, 0, 2*Math.PI);
							c.fill ();
						}
					}
				}

				draw_line (c);
				return false;
			});

			var actionbar = new Gtk.ActionBar ();
			actionbar.get_style_context ().add_class ("dm-actionbar");

            var new_button = new Gtk.Button ();
            new_button.has_tooltip = true;
            new_button.set_image (new Gtk.Image.from_icon_name ("document-new-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
            new_button.tooltip_text = (_("New file"));

            new_button.clicked.connect ((e) => {
                clear ();
            });

            actionbar.pack_start (new_button);

            var save_button = new Gtk.Button ();
            save_button.set_image (new Gtk.Image.from_icon_name ("document-save-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
            save_button.has_tooltip = true;
			save_button.tooltip_text = (_("Save file"));

			//save_button.clicked.connect ((e) => {
                // TODO: Implement saving.
            //});

            actionbar.pack_start (save_button);

            //  TODO: After I finish Line, do Curves.
            //  var line_curve_button = new Gtk.Button ();
            //  line_curve_button.set_image (new Gtk.Image.from_icon_name ("line-curve-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
			//  line_curve_button.has_tooltip = true;
			//  line_curve_button.tooltip_text = (_("Draw Curved Line"));
			//
			//  line_straight_button.clicked.connect ((e) => {
            //      TODO: Implement drawing curves with this button.
			//  });
			//
			//  actionbar.pack_end (line_curve_button);

            var line_straight_button = new Gtk.Button ();
            line_straight_button.set_image (new Gtk.Image.from_icon_name ("line-straight-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
			line_straight_button.has_tooltip = true;
			line_straight_button.tooltip_text = (_("Draw Line"));

			line_straight_button.clicked.connect ((e) => {
				da.queue_draw ();
            });

            actionbar.pack_end (line_straight_button);


            this.pack_end (actionbar, false, false, 0);
            this.pack_start (da, true, true, 0);
            this.get_style_context ().add_class ("dm-grid");
			show_all ();
		}

		public void clear () {
			paths = null;
			current_path = null;
			queue_draw ();
		}

		public void draw_line (Cairo.Context c) {
			c.set_source_rgba (0, 0, 0, 1);
			c.set_line_cap (Cairo.LineCap.ROUND);
			c.set_line_join (Cairo.LineJoin.ROUND);
			c.set_line_width (5);
			foreach (var path in paths) {
				int x = (int) Math.round(path.points.data.x / ratio) * ratio;
				int y = (int) Math.round(path.points.data.y / ratio) * ratio;
				print ("Drew line to: %d x %d\n", x,y);

				c.line_to (x, y);
			}
			c.stroke ();
		}
    }
}