/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.NewSecret: Gtk.Dialog {
    public Alohomora.SecretManager secret {get; construct;}

    private Granite.ValidatedEntry credential_name_entry;
    private Granite.ValidatedEntry username_entry;
    private Gtk.Entry pass_entry;
    private Granite.ValidatedEntry note_name_entry;
    private Gtk.TextView note;
    private Gtk.Stack stack;
    private Gtk.Widget add;

    public NewSecret (Alohomora.Window app_window, Alohomora.SecretManager secret_manager) {
        Object (
            title: _("Add New Secret"),
            transient_for: app_window,
            deletable: false,
            resizable: false,
            default_width: 330,
            modal: true,
            secret: secret_manager
        );
    }

    construct {
        var credential_name_label = new Gtk.Label (_("Name :"));
        credential_name_label.halign = Gtk.Align.END;
        credential_name_entry = new Granite.ValidatedEntry ();
        credential_name_entry.min_length = 1;
        credential_name_entry.changed.connect (update_form_state);
        credential_name_entry.placeholder_text = _("Eg. GitHub, AWS API Key, etc.");
        var username_label = new Gtk.Label (_("Username :"));
        username_label.halign = Gtk.Align.END;
        username_entry = new Granite.ValidatedEntry ();
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
        creds_grid.attach (username_label,        0, 1 ,1, 1);
        creds_grid.attach (username_entry,        1, 1, 2, 1);
        creds_grid.attach (pass_label,            0, 2, 1, 1);
        creds_grid.attach (pass_entry,            1, 2, 1, 1);
        creds_grid.attach (pass_regen_button,     2, 2, 1, 1);

        var note_name_label = new Gtk.Label (_("Name :"));
        note_name_label.halign = Gtk.Align.END;
        note_name_entry = new Granite.ValidatedEntry ();
        note_name_entry.min_length = 1;
        note_name_entry.changed.connect (update_form_state);
        note_name_entry.placeholder_text = _("Eg. SSH Key, SSL/TLS Certificates, etc.");
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

        stack = new Gtk.Stack ();
        stack.add_titled (creds_grid, "Credentials", _("Credentials"));
        stack.add_titled (note_grid, "Other", _("Secure Note"));
        stack.grab_focus ();
        stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
        stack.notify["visible-child"].connect (update_form_state);
        var stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.stack = stack;
        stack_switcher.can_focus = false;

        var dialog_content = get_content_area ();
        dialog_content.margin_top = 15;
        dialog_content.margin_bottom = 15;
        dialog_content.margin_start = 15;
        dialog_content.margin_end = 15;
        dialog_content.append (stack_switcher);
        dialog_content.append (stack);

        add_button (_("Cancel"), Gtk.ResponseType.CLOSE);
        add = add_button (_("Add Secret"), Gtk.ResponseType.APPLY);
        add.sensitive = false;

        response.connect (id => {
            if (id == Gtk.ResponseType.CLOSE) {
                destroy ();
            }
            else if (id == Gtk.ResponseType.APPLY) {
                var should_copy_pass = new Settings ("io.github.z0o0p.alohomora").get_boolean ("copy-new-pass");
                var display = Gdk.Display.get_default ();
                var clipboard = display.get_clipboard ();
                if (stack.visible_child_name == "Credentials") {
                    secret.new_secret.begin (Alohomora.Constants.SECRET_TYPE_CREDENTIAL, credential_name_entry.text, username_entry.text, pass_entry.text);
                    if (should_copy_pass) {
                        clipboard.set_text (pass_entry.text);
                    }
                }
                else if (stack.visible_child_name == "Other") {
                    secret.new_secret.begin (Alohomora.Constants.SECRET_TYPE_OTHER, note_name_entry.text, "", note.buffer.text);
                }
            }
        });

        secret.changed.connect (() => destroy ());
    }

    private void update_form_state () {
        if (stack.visible_child_name == "Credentials") {
            add.sensitive = credential_name_entry.is_valid && username_entry.is_valid;
        }
        else if (stack.visible_child_name == "Other") {
            add.sensitive = note_name_entry.is_valid;
        }

        if (add.sensitive) {
            add.add_css_class ("primary-background");
        }
        else {
            add.remove_css_class ("primary-background");
        }
    }
}
