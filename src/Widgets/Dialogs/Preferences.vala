/*
* Copyright (c) 2020 Taqmeel Zubeir
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
*
* Authored by: Taqmeel Zubeir <taqmeelzubeir.dev@gmail.com>
*/

public class Alohomora.Preferences: Gtk.Dialog {
    public Alohomora.SecretManager secret {get; construct;}

    private Gtk.Grid grid;
    private Gtk.Label sort_label;
    private Gtk.RadioButton ascending;
    private Gtk.RadioButton descending;

    public Preferences (Alohomora.Window app_window, Alohomora.SecretManager secret_manager) {
        Object (
            title: _("Preferences"),
            transient_for: app_window,
            deletable: false,
            resizable: false,
            modal: true,
            border_width: 10,
            secret: secret_manager
        );
    }

    construct {
        sort_label = new Gtk.Label (_("Sorting Order: "));
        ascending = new Gtk.RadioButton.with_label_from_widget (null, _("Ascending"));
        descending = new Gtk.RadioButton.with_label_from_widget (ascending, _("Descending"));
        descending.set_active (false);

        grid = new Gtk.Grid ();
        grid.row_spacing = 5;
        grid.column_spacing = 5;
        grid.halign = Gtk.Align.CENTER;
        grid.margin = 15;
        grid.attach (sort_label, 0, 0, 1, 1);
        grid.attach (ascending,  1, 0, 1, 1);
        grid.attach (descending, 2, 0, 1, 1);

        var dialog_content = get_content_area ();
        dialog_content.spacing = 5;
        dialog_content.pack_start (grid);
        dialog_content.show_all ();

        add_button (_("Close"), Gtk.ResponseType.CLOSE);
        var add = add_button (_("Apply"), Gtk.ResponseType.APPLY);
        add.get_style_context ().add_class ("suggested-button");

        response.connect (id => {
            if (id == Gtk.ResponseType.APPLY) {
                secret.order (ascending.active);
            }
            destroy ();
        });
    }
}
