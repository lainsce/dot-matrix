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
    public class Widgets.StatusBar : Gtk.Revealer {
        public MainWindow window;

        public StatusBar () {
            var actionbar = new Gtk.ActionBar ();
            actionbar.get_style_context ().add_class ("dm-actionbar");

            var new_button = new Gtk.Button ();
            new_button.has_tooltip = true;
            new_button.set_image (new Gtk.Image.from_icon_name ("document-new-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
            new_button.tooltip_text = (_("New file"));

            var save_button = new Gtk.Button ();
            save_button.set_image (new Gtk.Image.from_icon_name ("document-save-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
            save_button.has_tooltip = true;
            save_button.tooltip_text = (_("Save file"));

            var open_button = new Gtk.Button ();
            open_button.set_image (new Gtk.Image.from_icon_name ("document-open-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
			open_button.has_tooltip = true;
            open_button.tooltip_text = (_("Open…"));

            var line_curve_button = new Gtk.Button ();
            line_curve_button.set_image (new Gtk.Image.from_icon_name ("line-curve-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
			line_curve_button.has_tooltip = true;
            line_curve_button.tooltip_text = (_("Curved Lines"));

            var line_straight_button = new Gtk.Button ();
            line_straight_button.set_image (new Gtk.Image.from_icon_name ("line-straight-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
			line_straight_button.has_tooltip = true;
            line_straight_button.tooltip_text = (_("Lines"));

            actionbar.pack_start (new_button);
            actionbar.pack_start (open_button);
            actionbar.pack_start (save_button);
            actionbar.pack_end (line_straight_button);
            actionbar.pack_end (line_curve_button);

            this.add (actionbar);
        }
    }
}