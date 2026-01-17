/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.EditSecret: Gtk.Dialog {
    public Alohomora.SecretManager secret {get; construct;}
    public Secret.Item secret_item {get; construct;}

    private string credential_name;
    private string user_name;
    private string pin_status;
    private string user_pass;
    private Gtk.Entry credential_name_entry;
    private Gtk.Entry user_name_entry;
    private Gtk.Entry pass_entry;

    public EditSecret (Alohomora.Window app_window, Alohomora.SecretManager secret_manager, Secret.Item secretitem) {
        Object (
            title: _("Edit Secret"),
            transient_for: app_window,
            deletable: false,
            resizable: false,
            modal: true,
            secret: secret_manager,
            secret_item: secretitem
        );
    }

    construct {
        load_secret_attributes ();

        var credential_name_label = new Gtk.Label (_("Name :"));
        credential_name_label.halign = Gtk.Align.END;
        credential_name_entry = new Gtk.Entry ();
        credential_name_entry.text = credential_name;
        var user_name_label = new Gtk.Label (_("Username :"));
        user_name_label.halign = Gtk.Align.END;
        user_name_entry = new Gtk.Entry ();
        user_name_entry.text = user_name;
        var pass_label = new Gtk.Label (_("Password :"));
        pass_label.halign = Gtk.Align.END;
        pass_entry = new Gtk.Entry ();
        pass_entry.visibility = false;
        pass_entry.secondary_icon_name = "image-red-eye-symbolic";
        pass_entry.secondary_icon_tooltip_text = _("Show Password");
        pass_entry.icon_press.connect(() => pass_entry.visibility = !pass_entry.visibility);

        var grid = new Gtk.Grid ();
        grid.row_spacing = 5;
        grid.column_spacing = 5;
        grid.halign = Gtk.Align.CENTER;
        grid.attach (credential_name_label, 0, 0, 1, 1);
        grid.attach (credential_name_entry, 1, 0, 1, 1);
        grid.attach (user_name_label,       0, 1 ,1, 1);
        grid.attach (user_name_entry,       1, 1, 1, 1);
        grid.attach (pass_label,            0, 2, 1, 1);
        grid.attach (pass_entry,            1, 2, 1, 1);

        var dialog_content = get_content_area ();
        dialog_content.margin_top = 15;
        dialog_content.margin_bottom = 15;
        dialog_content.margin_start = 15;
        dialog_content.margin_end = 15;
        dialog_content.append (grid);

        add_button (_("Cancel"), Gtk.ResponseType.CLOSE);
        var add = add_button (_("Edit Secret"), Gtk.ResponseType.APPLY);
        add.add_css_class ("suggested-button");

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
