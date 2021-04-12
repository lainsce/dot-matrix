/*
* Copyright (c) 2021 Lains
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
    public class Widgets.Dialog : Gtk.MessageDialog {
        public Dialog () {
            Object (
                image: new Gtk.Image.from_icon_name ("dialog-information", Gtk.IconSize.DIALOG),
                text: _("Save Image?"),
                secondary_text: _("There are unsaved changes to the image. If they aren't saved, changes will be lost forever.")
            );
        }
        construct {
            var save = add_button (_("Save"), Gtk.ResponseType.OK);
            var cws = add_button (_("Close Without Saving"), Gtk.ResponseType.NO);
            var cancel = add_button (_("Cancel"), Gtk.ResponseType.CANCEL) as Gtk.Button;
            cancel.clicked.connect (() => { destroy (); });
        }
    }
}
