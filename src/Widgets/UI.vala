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
		public bool is_curve {get; set;}
    }

    public class Widgets.UI : Gtk.VBox {
        public MainWindow window;
        public Gtk.DrawingArea da;

        GLib.List<Path> paths = new GLib.List<Path> ();
		Path current_path = new Path ();

		private int ratio = 25;
		private int line_thickness = 5;

        public UI () {
            da = new Gtk.DrawingArea ();
            da.expand = true;
			da.set_size_request(this.get_allocated_width(),this.get_allocated_height());

			da.add_events (Gdk.EventMask.BUTTON_PRESS_MASK);

			da.button_press_event.connect ((e) => {
				current_path.points.append (new Point (e.x, e.y));
				da.queue_draw ();
				return false;
			});

			da.draw.connect ((c) => {
				int i, j;
				int h = da.get_allocated_height ();
				int w = da.get_allocated_width ();
				c.set_line_width (2);
				for (i = 0; i <= w / ratio; i++) {
					for (j = 0; j <= h / ratio; j++) {
						if ((i - 1) % 4 == 0 && (j - 1) % 4 == 0) {
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

				draws (c);
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

			save_button.clicked.connect ((e) => {
                // TODO: Implement saving.
            });

			actionbar.pack_start (save_button);

			var line_thickness_button = new Gtk.Button ();
            line_thickness_button.set_image (new Gtk.Image.from_icon_name ("line-thickness-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
            line_thickness_button.has_tooltip = true;
			line_thickness_button.tooltip_text = (_("Change Line Thickness"));
			var line_thickness_label = new Gtk.Label (line_thickness.to_string());
			line_thickness_label.get_style_context ().add_class ("dm-text");
			line_thickness_label.valign = Gtk.Align.CENTER;
			line_thickness_label.margin_top = 3;

			line_thickness_button.clicked.connect ((e) => {
                if (line_thickness != 25) {
					line_thickness++;
					line_thickness_label.label = line_thickness.to_string ();
					queue_draw ();
				} else {
					line_thickness = 5;
					line_thickness_label.label = line_thickness.to_string ();
					queue_draw ();
				}
			});

			var line_thickness_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 3);
			line_thickness_box.pack_start (line_thickness_button);
			line_thickness_box.pack_start (line_thickness_label);

			actionbar.pack_start (line_thickness_box);

            var line_curve_button = new Gtk.Button ();
            line_curve_button.set_image (new Gtk.Image.from_icon_name ("line-curve-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
			line_curve_button.has_tooltip = true;
			line_curve_button.tooltip_text = (_("Draw Curved Line"));

			line_curve_button.clicked.connect ((e) => {
				paths.append (current_path);
				current_path.is_curve = true;
				current_path = new Path ();
				da.queue_draw ();
			});

			actionbar.pack_end (line_curve_button);

            var line_straight_button = new Gtk.Button ();
            line_straight_button.set_image (new Gtk.Image.from_icon_name ("line-straight-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
			line_straight_button.has_tooltip = true;
			line_straight_button.tooltip_text = (_("Draw Line"));

			line_straight_button.clicked.connect ((e) => {
				paths.append (current_path);
				current_path.is_curve = false;
				current_path = new Path ();
				da.queue_draw ();
            });

            actionbar.pack_end (line_straight_button);

            this.pack_end (actionbar, false, false, 0);
            this.pack_start (da, true, true, 0);
			this.get_style_context ().add_class ("dm-grid");
			this.margin = 1;
			show_all ();
		}

		public void clear () {
			paths = null;
			current_path = new Path ();
			queue_draw ();
		}

		public void draws (Cairo.Context c) {
			c.set_line_cap (Cairo.LineCap.ROUND);
			c.set_line_join (Cairo.LineJoin.ROUND);
			c.set_line_width (line_thickness);

			if (current_path != null) {
				c.set_source_rgba (0, 0, 0, 0.5);
				draw_path (c, current_path);
			}
			c.stroke ();

			c.set_source_rgba (0, 0, 0, 1);
			foreach (var path in paths) {
				if (path.is_curve == true) {
					draw_curve (c, path);
				} else if (path.is_curve == false) {
					draw_path (c, path);
				}
			}
			c.stroke ();
		}

		private void draw_path (Cairo.Context c, Path path) {
			if (path.points.length () < 2) {
				return;
			}

			for (int i = 0; i < path.points.length () - 1; i+=1) {
				int start_x = (int) Math.round(path.points.nth_data(i).x / ratio) * ratio;
				int start_y = (int) Math.round(path.points.nth_data(i).y / ratio) * ratio;

				int end_x = (int) Math.round(path.points.nth_data(i+1).x / ratio) * ratio;
				int end_y = (int) Math.round(path.points.nth_data(i+1).y / ratio) * ratio;

				c.move_to(start_x, start_y);
				c.line_to (end_x, end_y);
			}
		}

		private void draw_curve (Cairo.Context c, Path path) {
			if (path.points.length () < 2) {
				return;
			}

			for (int i = 0; i < path.points.length () - 1; i+=1) {
				int start_x = (int) Math.round(path.points.nth_data(i).x / ratio) * ratio;
				int start_y = (int) Math.round(path.points.nth_data(i).y / ratio) * ratio;

				int end_x = (int) Math.round(path.points.nth_data(i+1).x / ratio) * ratio;
				int end_y = (int) Math.round(path.points.nth_data(i+1).y / ratio) * ratio;

				c.move_to(start_x, start_y);
				c.curve_to (start_x, start_y, start_x, end_y, end_x, end_y);
			}
		}
    }
}