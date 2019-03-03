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
		public List<Point> points = null;
    }

    public class Area : Gtk.DrawingArea {
        private int ratio = 25;
        private int big_dot = 4;
        List<Path> paths = new List<Path> ();
		Path current_path = null;

        public Area () {
            add_events (Gdk.EventMask.BUTTON_PRESS_MASK   |
                    Gdk.EventMask.BUTTON_RELEASE_MASK     |
                    Gdk.EventMask.BUTTON_MOTION_MASK
            );
        }

        public signal void stroke_added (double[] coordinates);
		public signal void stroke_removed (uint n_strokes);

		public override bool button_press_event (Gdk.EventButton event) {
			current_path = new Path ();
			current_path.points.append (new Point (event.x, event.y));
			paths.append (current_path);
			return false;
		}

		public override bool button_release_event (Gdk.EventButton event) {
			Gtk.Allocation allocation;
			get_allocation (out allocation);
			double[] coordinates = new double[current_path.points.length () * 2];
			int i = 0;
			foreach (var point in current_path.points) {
				coordinates[i] = point.x / (double)allocation.width;
				coordinates[i + 1] = point.y / (double)allocation.height;
			}
			stroke_added (coordinates);

			current_path = null;
			return false;
		}

		public override bool motion_notify_event (Gdk.EventMotion event) {
			Gtk.Allocation allocation;
			get_allocation (out allocation);

			double x = event.x.clamp ((double)allocation.x,
									  (double)(ratio + allocation.width));
			double y = event.y.clamp ((double)allocation.y,
									  (double)(ratio + allocation.height));
			Point last = current_path.points.last ().data;
			double dx = x - last.x;
			double dy = y - last.y;
			if (Math.floor (dx * dx + dy * dy) > 10.0) {
				current_path.points.append (new Point (x, y));
				queue_draw ();
			}
			return false;
        }

        public override bool draw (Cairo.Context c) {
            int i, j;
			int h = get_allocated_height ();
			int w = get_allocated_width ();
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

			c.set_source_rgba (0, 0, 0, 1);
			c.set_line_cap (Cairo.LineCap.ROUND);
			c.set_line_join (Cairo.LineJoin.ROUND);
			c.set_line_width (5);
			foreach (var path in paths) {
				foreach (var point in path.points.next) {
					int x = (int) Math.floor(Math.round(point.x / ratio) * ratio);
					int y = (int) Math.floor(Math.round(point.y / ratio) * ratio);
					c.line_to (x, y);
				}
				c.stroke ();
			}
			return true;
		}

		public double lerp(double start, double end, int t) {
			return start + t * (end - start);
		}

		public void clear () {
			paths = null;
			current_path = null;
			queue_draw ();
			stroke_removed (0);
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
				stroke_removed (1);
			}
		}
    }

    public class Widgets.UI : Gtk.VBox {
        public MainWindow window;
        public Area da;

        List<Path> paths = new List<Path> ();
        Path current_path = null;

        public signal void stroke_added (double[] coordinates);
		public signal void stroke_removed (uint n_strokes);

        public UI () {
            da = new Area ();
            da.expand = true;
            da.set_size_request(this.get_allocated_width(),this.get_allocated_height());

            da.stroke_added.connect ((coordinates) => {
                stroke_added (coordinates);
            });
            da.stroke_removed.connect ((n_strokes) => {
                stroke_removed (n_strokes);
			});

			var actionbar = new Gtk.ActionBar ();
			actionbar.get_style_context ().add_class ("dm-actionbar");

            var new_button = new Gtk.Button ();
            new_button.has_tooltip = true;
            new_button.set_image (new Gtk.Image.from_icon_name ("document-new-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
            new_button.tooltip_text = (_("New file"));

            new_button.clicked.connect ((e) => {
                da.clear ();
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
			//  line_curve_button.tooltip_text = (_("Curved Lines"));
			//
			//  line_straight_button.clicked.connect ((e) => {
            //      TODO: Implement drawing curves with this button.
			//  });
			//
			//  actionbar.pack_end (line_curve_button);

            var line_straight_button = new Gtk.Button ();
            line_straight_button.set_image (new Gtk.Image.from_icon_name ("line-straight-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
			line_straight_button.has_tooltip = true;
			line_straight_button.tooltip_text = (_("Lines"));

			//line_straight_button.clicked.connect ((e) => {
                // TODO: Implement drawing lines with this button.
            //});

            actionbar.pack_end (line_straight_button);


            this.pack_end (actionbar, false, false, 0);
            this.pack_start (da, true, true, 0);
            this.get_style_context ().add_class ("dm-grid");
            show_all ();
        }
    }
}