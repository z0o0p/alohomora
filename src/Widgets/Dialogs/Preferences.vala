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

    private Settings settings;
    private Gtk.Grid grid;
    private Gtk.Label sort_label;
    private Gtk.RadioButton ascending;
    private Gtk.RadioButton descending;
    private Gtk.Label copy_label;
    private Gtk.RadioButton copy_yes;
    private Gtk.RadioButton copy_no;
    private Gtk.Label pass_length_label;
    private Gtk.SpinButton pass_length;

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
        settings = new Settings ("com.github.z0o0p.alohomora");

        sort_label = new Gtk.Label (_("Sorting Order: "));
        sort_label.halign = Gtk.Align.END;
        ascending = new Gtk.RadioButton.with_label_from_widget (null, _("Ascending"));
        descending = new Gtk.RadioButton.with_label_from_widget (ascending, _("Descending"));
        descending.set_active (!settings.get_boolean ("sort-ascending"));

        copy_label = new Gtk.Label (_("Copy New Password After Adding: "));
        copy_label.halign = Gtk.Align.END;
        copy_yes = new Gtk.RadioButton.with_label_from_widget (null, _("Yes"));
        copy_no = new Gtk.RadioButton.with_label_from_widget (copy_yes, _("No"));
        copy_no.set_active (!settings.get_boolean ("copy-new-pass"));

        pass_length_label = new Gtk.Label (_("Generated Password Length: "));
        pass_length_label.halign = Gtk.Align.END;
        pass_length = new Gtk.SpinButton.with_range (8, 24, 1);
        pass_length.set_value (settings.get_int ("gen-pass-length"));

        grid = new Gtk.Grid ();
        grid.row_spacing = 10;
        grid.column_spacing = 5;
        grid.halign = Gtk.Align.CENTER;
        grid.margin = 10;
        grid.attach (sort_label,        0, 0, 1, 1);
        grid.attach (ascending,         1, 0, 1, 1);
        grid.attach (descending,        2, 0, 1, 1);
        grid.attach (copy_label,        0, 1, 1, 1);
        grid.attach (copy_yes,          1, 1, 1, 1);
        grid.attach (copy_no,           2, 1, 1, 1);
        grid.attach (pass_length_label, 0, 2, 1, 1);
        grid.attach (pass_length,       1, 2, 2, 1);

        var dialog_content = get_content_area ();
        dialog_content.spacing = 5;
        dialog_content.pack_start (grid);
        dialog_content.show_all ();

        add_button (_("Close"), Gtk.ResponseType.CLOSE);
        var add = add_button (_("Apply"), Gtk.ResponseType.APPLY);
        add.get_style_context ().add_class ("suggested-button");

        response.connect (id => {
            if (id == Gtk.ResponseType.APPLY) {
                settings.set_boolean ("sort-ascending", ascending.active);
                settings.set_boolean ("copy-new-pass", copy_yes.active);
                settings.set_int ("gen-pass-length", (int)pass_length.value);
                secret.ordering_changed ();
            }
            destroy ();
        });
    }
}
