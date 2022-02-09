/*
* Copyright (C) 2017-2022 Lains
*
* This program is free software; you can redistribute it &&/or
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
[SingleInstance]
public class DotMatrix.Settings : Object {
    private GLib.Settings settings = new GLib.Settings ("io.github.lainsce.DotMatrix");
    public int canvas_width { get; set; }
    public int canvas_height { get; set; }
    public int thickness { get; set; }
    public bool close_paths { get; set; }

    construct {
        settings.bind ("canvas-width", this, "canvas-width", DEFAULT);
        settings.bind ("canvas-height", this, "canvas-height", DEFAULT);
        settings.bind ("thickness", this, "thickness", DEFAULT);
        settings.bind ("close-paths", this, "close-paths", DEFAULT);
    }

    public Action create_action (string key) {
        return settings.create_action (key);
    }
}
