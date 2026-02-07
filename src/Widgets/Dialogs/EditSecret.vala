/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.EditSecret: Gtk.Dialog {
    public Alohomora.SecretManager secret {get; construct;}
    public Secret.Item secret_item {get; construct;}

    private string secret_id;
    private string secret_type;
    private string credential_name;
    private string user_name;
    private string user_pass;
    private string pin_status;
    private Granite.ValidatedEntry credential_name_entry;
    private Granite.ValidatedEntry username_entry;
    private Gtk.Entry pass_entry;
    private Granite.ValidatedEntry note_name_entry;
    private Gtk.TextView note;
    private Gtk.Widget edit_button;

    public EditSecret (Alohomora.Window app_window, Alohomora.SecretManager secret_manager, Secret.Item secretitem) {
        Object (
            title: _("Edit Secret"),
            transient_for: app_window,
            deletable: false,
            resizable: false,
            default_width: 330,
            modal: true,
            secret: secret_manager,
            secret_item: secretitem
        );
    }

    construct {
        load_secret_attributes ();
        update_form_state ();

        var credential_name_label = new Gtk.Label (_("Name :"));
        credential_name_label.halign = Gtk.Align.END;
        credential_name_entry = new Granite.ValidatedEntry ();
        credential_name_entry.text = credential_name;
        credential_name_entry.min_length = 1;
        credential_name_entry.changed.connect (update_form_state);
        var user_name_label = new Gtk.Label (_("Username :"));
        user_name_label.halign = Gtk.Align.END;
        username_entry = new Granite.ValidatedEntry ();
        username_entry.text = user_name;
        username_entry.min_length = 1;
        username_entry.changed.connect (update_form_state);
        var pass_label = new Gtk.Label (_("Password :"));
        pass_label.halign = Gtk.Align.END;
        pass_entry = new Gtk.Entry ();
        pass_entry.visibility = false;
        pass_entry.secondary_icon_name = "eye-open-negative-filled-symbolic";
        pass_entry.secondary_icon_tooltip_text = _("Show Password");
        pass_entry.icon_press.connect (() => {
            pass_entry.visibility = !pass_entry.visibility;
            pass_entry.secondary_icon_name = ((pass_entry.visibility) ? "eye-not-looking-symbolic" : "eye-open-negative-filled-symbolic");
            pass_entry.secondary_icon_tooltip_text = ((pass_entry.visibility) ? _("Hide Password") : _("Show Password"));
        });
        var pass_regen_button = new Gtk.Button.from_icon_name ("view-refresh-symbolic");
        pass_regen_button.tooltip_text = _("Regenerate Password");
        pass_regen_button.clicked.connect (() => pass_entry.text = Alohomora.PasswordGenerator.generate ());
        var creds_grid = new Gtk.Grid ();
        creds_grid.row_spacing = 5;
        creds_grid.column_spacing = 5;
        creds_grid.margin_top = 15;
        creds_grid.hexpand = true;
        creds_grid.halign = Gtk.Align.CENTER;
        creds_grid.attach (credential_name_label, 0, 0, 1, 1);
        creds_grid.attach (credential_name_entry, 1, 0, 2, 1);
        creds_grid.attach (user_name_label,       0, 1 ,1, 1);
        creds_grid.attach (username_entry,        1, 1, 2, 1);
        creds_grid.attach (pass_label,            0, 2, 1, 1);
        creds_grid.attach (pass_entry,            1, 2, 1, 1);
        creds_grid.attach (pass_regen_button,     2, 2, 1, 1);

        var note_name_label = new Gtk.Label (_("Name :"));
        note_name_label.halign = Gtk.Align.END;
        note_name_entry = new Granite.ValidatedEntry ();
        note_name_entry.text = credential_name;
        note_name_entry.min_length = 1;
        note_name_entry.changed.connect (update_form_state);
        var note_label = new Gtk.Label (_("Note :"));
        note_label.halign = Gtk.Align.END;
        note = new Gtk.TextView ();
        note.left_margin = 5;
        note.top_margin = 5;
        note.right_margin = 5;
        note.bottom_margin = 5;
        note.wrap_mode = Gtk.WrapMode.CHAR;
        note.add_css_class (Granite.STYLE_CLASS_TERMINAL);
        var note_scroll_view = new Gtk.ScrolledWindow ();
        note_scroll_view.hscrollbar_policy = Gtk.PolicyType.NEVER;
        note_scroll_view.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
        note_scroll_view.hexpand = true;
        note_scroll_view.halign = Gtk.Align.FILL;
        note_scroll_view.vexpand = true;
        note_scroll_view.valign = Gtk.Align.FILL;
        note_scroll_view.set_child (note);
        var note_grid = new Gtk.Grid ();
        note_grid.height_request = 100;
        note_grid.width_request = 275;
        note_grid.row_spacing = 5;
        note_grid.column_spacing = 5;
        note_grid.margin_top = 15;
        note_grid.hexpand = true;
        note_grid.halign = Gtk.Align.FILL;
        note_grid.attach (note_name_label,       0, 0, 1, 1);
        note_grid.attach (note_name_entry,       1, 0, 1, 1);
        note_grid.attach (note_label,            0, 1, 1, 1);
        note_grid.attach (note_scroll_view,      1, 1, 1, 1);

        var dialog_content = get_content_area ();
        dialog_content.margin_top = 15;
        dialog_content.margin_bottom = 15;
        dialog_content.margin_start = 15;
        dialog_content.margin_end = 15;
        if (secret_type == Alohomora.Constants.SECRET_TYPE_CREDENTIAL) dialog_content.append (creds_grid);
        else dialog_content.append (note_grid);

        add_button (_("Cancel"), Gtk.ResponseType.CLOSE);
        edit_button = add_button (_("Edit Secret"), Gtk.ResponseType.APPLY);
        edit_button.add_css_class ("primary-background");

        response.connect (id => {
            if (id == Gtk.ResponseType.CLOSE) {
                destroy ();
            }
            else if (id == Gtk.ResponseType.APPLY) {
                if (secret_type == Alohomora.Constants.SECRET_TYPE_CREDENTIAL) {
                    secret.edit_secret.begin (secret_id, credential_name_entry.text, username_entry.text, pass_entry.text, pin_status);
                }
                else if (secret_type == Alohomora.Constants.SECRET_TYPE_OTHER) {
                    secret.edit_secret.begin (secret_id, note_name_entry.text, "", note.buffer.text, pin_status);
                }
            }
        });

        secret.changed.connect (() => destroy());
    }

    private void load_secret_attributes () {
        var secret_attributes = secret_item.get_attributes ();
        secret_id = secret_attributes.get ("secret-id");
        secret_type = secret_attributes.get ("secret-type");
        credential_name = secret_attributes.get ("credential-name");
        user_name = secret_attributes.get ("user-name");
        pin_status = (secret_attributes.get ("pinned") == null) ? "false" : secret_attributes.get ("pinned");
        secret.load_secret_value.begin (
            secret_item,
            (obj, res) => {
                secret.load_secret_value.end (res, out user_pass);
                pass_entry.text = user_pass;
                note.buffer.text = user_pass;
            }
        );
    }

    private void update_form_state () {
        if (secret_type == Alohomora.Constants.SECRET_TYPE_CREDENTIAL) {
            edit_button.sensitive = credential_name_entry.is_valid && username_entry.is_valid && pass_entry.text != "";
        }
        else if (secret_type == Alohomora.Constants.SECRET_TYPE_OTHER) {
            edit_button.sensitive = note_name_entry.is_valid && note.buffer.text != "";
        }
    }
}
