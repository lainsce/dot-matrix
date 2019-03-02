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

        public Grid () {
            var d = new Gtk.DrawingArea ();
            d.expand = true;
		    d.draw.connect ((c) => {
                int i, j;
                for (i = 0; i < 25; i++) {
                    for (j = 0; j < 25; j++) {
                        if (i % 4 == 0 && j % 4 == 0) {
                            c.set_source_rgba (0.7, 0.7, 0.7, 1);
                            c.arc ((i+1)*25, (j+1)*25, 3, 0, 2*Math.PI);
                            c.fill ();
                        } else {
                            c.set_source_rgba (0.8, 0.8, 0.8, 1);
                            c.arc ((i+1)*25, (j+1)*25, 2, 0, 2*Math.PI);
                            c.fill ();
                        }
                    }
                }
                return true;
            });
            this.attach (d,1,1,1,1);

            this.get_style_context ().add_class ("dm-grid");

            show_all ();
        }
    }
}