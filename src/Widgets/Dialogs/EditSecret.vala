/*
* Copyright (c) 2021 Taqmeel Zubeir
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

public class Alohomora.EditSecret: Gtk.Dialog {
    public Alohomora.SecretManager secret {get; construct;}
    public Secret.Item secret_item {get; construct;}

    private string credential_name;
    private string user_name;
    private string pin_status;
    private string user_pass;
    private Gtk.Grid grid;
    private Gtk.Label credential_name_label;
    private Gtk.Entry credential_name_entry;
    private Gtk.Label user_name_label;
    private Gtk.Entry user_name_entry;
    private Gtk.Label pass_label;
    private Gtk.Entry pass_entry;

    public EditSecret (Alohomora.Window app_window, Alohomora.SecretManager secret_manager, Secret.Item secretitem) {
        Object (
            title: _("Edit Secret"),
            transient_for: app_window,
            deletable: false,
            resizable: false,
            modal: true,
            border_width: 10,
            secret: secret_manager,
            secret_item: secretitem
        );
    }

    construct {
        load_secret_attributes ();

        credential_name_label = new Gtk.Label (_("Name :"));
        credential_name_label.halign = Gtk.Align.END;
        credential_name_entry = new Gtk.Entry ();
        credential_name_entry.text = credential_name;
        user_name_label = new Gtk.Label (_("Username :"));
        user_name_label.halign = Gtk.Align.END;
        user_name_entry = new Gtk.Entry ();
        user_name_entry.text = user_name;
        pass_label = new Gtk.Label (_("Password :"));
        pass_label.halign = Gtk.Align.END;
        pass_entry = new Gtk.Entry ();
        pass_entry.visibility = false;
        pass_entry.caps_lock_warning = false;
        pass_entry.secondary_icon_name = "image-red-eye-symbolic";
        pass_entry.secondary_icon_tooltip_text = _("Show Password");
        pass_entry.icon_press.connect(() => pass_entry.visibility = !pass_entry.visibility);

        grid = new Gtk.Grid ();
        grid.row_spacing = 5;
        grid.column_spacing = 5;
        grid.halign = Gtk.Align.CENTER;
        grid.margin = 15;
        grid.attach (credential_name_label, 0, 0, 1, 1);
        grid.attach (credential_name_entry, 1, 0, 1, 1);
        grid.attach (user_name_label,       0, 1 ,1, 1);
        grid.attach (user_name_entry,       1, 1, 1, 1);
        grid.attach (pass_label,            0, 2, 1, 1);
        grid.attach (pass_entry,            1, 2, 1, 1);

        var dialog_content = get_content_area ();
        dialog_content.spacing = 5;
        dialog_content.pack_start (grid);
        dialog_content.show_all ();

        add_button (_("Cancel"), Gtk.ResponseType.CLOSE);
        var add = add_button (_("Edit Secret"), Gtk.ResponseType.APPLY);
        add.get_style_context ().add_class ("suggested-button");

        response.connect (id => {
            if (id == Gtk.ResponseType.CLOSE) {
                destroy ();
            }
            else if (id == Gtk.ResponseType.APPLY) {
                if (credential_name_entry.text != "" && user_name_entry.text != "" && pass_entry.text != "" ) {
                        secret.edit_secret.begin (credential_name, credential_name_entry.text, user_name, user_name_entry.text, pass_entry.text, pin_status);
                }
            }
        });

        secret.changed.connect (() => destroy());
    }

    private void load_secret_attributes () {
        var secret_attributes = secret_item.get_attributes ();
        credential_name = secret_attributes.get ("credential-name");
        user_name = secret_attributes.get ("user-name");
        pin_status = (secret_attributes.get ("pinned") == null) ? "false" : secret_attributes.get ("pinned");
        secret.load_secret_value.begin (
            secret_item,
            (obj, res) => {
                secret.load_secret_value.end(res, out user_pass);
                pass_entry.text = user_pass;
            }
        );
    }
}
