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
            int i, j;

            for (i = 0; i < 16; i++) {
                make_dot ();
                this.attach (dot, 0, i, 1, 1);
                for (j = 0; j < 21; j++) {
                    make_dot ();
                    this.attach (dot, j, i, 1, 1);
                }
            }
            show_all ();
        }

        public void make_dot () {
            dot = new Gtk.ToggleButton ();
            dot.get_style_context ().add_class ("flat");
            dot.set_size_request (24,24);
            dot.set_image (new Gtk.Image.from_icon_name ("media-record-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
        }
    }
}