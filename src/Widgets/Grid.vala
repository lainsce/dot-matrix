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
    public class Widgets.Grid : Gtk.EventBox {
        public MainWindow window;

        public Grid () {
            events |= Gdk.EventMask.KEY_PRESS_MASK;
            events |= Gdk.EventMask.KEY_RELEASE_MASK;

            var clutter = new GtkClutter.Embed ();
            var stage = (Clutter.Stage)clutter.get_stage ();
            stage.background_color = {250, 250, 250, 255};

            var actor = new Clutter.Actor ();
            actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 0));
            actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.HEIGHT, 0));

            stage.add_child (actor);

            this.button_press_event.connect ((event) => {
                return false;
            });

            this.button_release_event.connect ((event) => {
                return false;
            });

            add (clutter);
            show_all ();
        }
    }
}