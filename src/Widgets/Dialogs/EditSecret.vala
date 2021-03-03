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

public class Alohomora.EditSecret: Gtk.Dialog {
    public Alohomora.SecretManager secret {get; construct;}
    public Secret.Item secret_item {get; construct;}

    private Gtk.Grid grid;
    private Gtk.Label credential_name_label;
    private Gtk.Entry credential_name;
    private Gtk.Label username_label;
    private Gtk.Entry username;
    private Gtk.Label pass_label;
    private Gtk.Entry pass;

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
        var secret_attributes = secret_item.get_attributes ();
        var credentialname = secret_attributes.get ("credential-name");
        var user_name = secret_attributes.get ("user-name");
        var pin_status = secret_attributes.get ("pinned");
        var user_pass = "";

        credential_name_label = new Gtk.Label (_("Name :"));
        credential_name_label.halign = Gtk.Align.END;
        credential_name = new Gtk.Entry ();
        credential_name.text = credentialname;
        username_label = new Gtk.Label (_("Username :"));
        username_label.halign = Gtk.Align.END;
        username = new Gtk.Entry ();
        username.text = user_name;
        pass_label = new Gtk.Label (_("Password :"));
        pass_label.halign = Gtk.Align.END;
        pass = new Gtk.Entry ();
        pass.visibility = false;
        pass.caps_lock_warning = false;
        pass.secondary_icon_name = "image-red-eye-symbolic";
        pass.secondary_icon_tooltip_text = _("Show Password");
        pass.icon_press.connect(() => pass.visibility = !pass.visibility);
        secret.load_secret_value.begin(
            secret_item,
            (obj, res) => {
                secret.load_secret_value.end(res, out user_pass);
                pass.text = user_pass;
            }
        );

        grid = new Gtk.Grid ();
        grid.row_spacing = 5;
        grid.column_spacing = 5;
        grid.halign = Gtk.Align.CENTER;
        grid.margin = 15;
        grid.attach (credential_name_label, 0, 0, 1, 1);
        grid.attach (credential_name,       1, 0, 1, 1);
        grid.attach (username_label,        0, 1 ,1, 1);
        grid.attach (username,              1, 1, 1, 1);
        grid.attach (pass_label,            0, 2, 1, 1);
        grid.attach (pass,                  1, 2, 1, 1);

        var dialog_content = get_content_area ();
        dialog_content.spacing = 5;
        dialog_content.pack_start (grid);
        dialog_content.show_all ();

        add_button (_("Cancel"), Gtk.ResponseType.CLOSE);
        var add = add_button (_("Edit Secret"), Gtk.ResponseType.APPLY);
        add.get_style_context ().add_class ("suggested-button");

        response.connect (id => {
            if (id == Gtk.ResponseType.CLOSE)
                destroy ();
            else if (id == Gtk.ResponseType.APPLY)
                if (credential_name.text != "" && username.text != "" && pass.text != "" )
                    if (credential_name.text != credentialname || username.text != user_name || pass.text != user_pass)
                        secret.edit_secret.begin (credentialname, credential_name.text, user_name, username.text, pass.text, pin_status);
        });

        secret.changed.connect (() => destroy());
    }
}
