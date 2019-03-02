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
    public class Widgets.Grid : Gtk.Grid {
        public MainWindow window;
        private Gtk.ToggleButton dot;

        public Grid () {
            this.get_style_context ().add_class ("dm-grid");
            this.halign = Gtk.Align.CENTER;
            this.valign = Gtk.Align.CENTER;
            this.row_spacing = 6;
            this.column_spacing = 6;
            this.row_homogeneous = true;
            int i, j;

            for (i = 0; i < 17; i++) {
                for (j = 0; j < 17; j++) {
                    if (j % 4 == 0 && i % 4 == 0) {
                        make_dot ();
                        dot.set_image (new Gtk.Image.from_icon_name ("dot-symbolic", ((Gtk.IconSize)8)));
                    } else {
                        make_dot ();
                        dot.set_image (new Gtk.Image.from_icon_name ("dot-symbolic", ((Gtk.IconSize)4)));
                    }
                    this.attach (dot, j, i, 1, 1);
                }
            }
            show_all ();
        }

        public void make_dot () {
            dot = new Gtk.ToggleButton ();
            dot.halign = Gtk.Align.CENTER;
            dot.valign = Gtk.Align.CENTER;
            dot.set_size_request (8,8);
            dot.get_style_context ().add_class ("flat");
        }
    }
}