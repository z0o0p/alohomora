/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.NewSecret: Gtk.Dialog {
    public Alohomora.SecretManager secret {get; construct;}

    private Gtk.Grid grid;
    private Gtk.Label credential_name_label;
    private Gtk.Entry credential_name;
    private Gtk.Label username_label;
    private Gtk.Entry username;
    private Gtk.Label pass_label;
    private Gtk.Entry gen_pass;
    private Gtk.Entry exist_pass;
    private Gtk.Stack stack;
    private Gtk.StackSwitcher stack_switcher;

    public NewSecret (Alohomora.Window app_window, Alohomora.SecretManager secret_manager) {
        Object (
            title: _("Add New Secret"),
            transient_for: app_window,
            deletable: false,
            resizable: false,
            modal: true,
            secret: secret_manager
        );
    }

    construct {
        credential_name_label = new Gtk.Label (_("Name :"));
        credential_name_label.halign = Gtk.Align.END;
        credential_name = new Gtk.Entry();
        credential_name.placeholder_text = _("Eg. GitHub, Facebook, etc.");

        username_label = new Gtk.Label (_("Username :"));
        username_label.halign = Gtk.Align.END;
        username = new Gtk.Entry ();

        pass_label = new Gtk.Label (_("Password :"));
        pass_label.halign = Gtk.Align.END;
        gen_pass = new Gtk.Entry ();
        gen_pass.text = Alohomora.PasswordGenerator.generate ();
        gen_pass.secondary_icon_name = "view-refresh-symbolic";
        gen_pass.secondary_icon_tooltip_text = _("Re-Generate Password");
        gen_pass.icon_press.connect (() => gen_pass.text = Alohomora.PasswordGenerator.generate ());
        exist_pass = new Gtk.Entry ();
        exist_pass.visibility = false;
        exist_pass.secondary_icon_name = "image-red-eye-symbolic";
        exist_pass.secondary_icon_tooltip_text = _("Show Password");
        exist_pass.icon_press.connect (() => exist_pass.visibility = !exist_pass.visibility);

        stack = new Gtk.Stack ();
        stack.add_titled (gen_pass, "Generate", _("Auto-Generate Password"));
        stack.add_titled (exist_pass, "Existing", _("Use Existing Password"));
        stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
        stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.stack = stack;

        grid = new Gtk.Grid ();
        grid.row_spacing = 5;
        grid.column_spacing = 5;
        grid.halign = Gtk.Align.CENTER;
        grid.margin_top = 20;
        grid.margin_bottom = 20;
        grid.margin_start = 20;
        grid.margin_end = 20;
        grid.attach (credential_name_label, 0, 0, 1, 1);
        grid.attach (credential_name,       1, 0, 1, 1);
        grid.attach (username_label,        0, 1 ,1, 1);
        grid.attach (username,              1, 1, 1, 1);
        grid.attach (pass_label,            0, 2, 1, 1);
        grid.attach (stack,                 1, 2, 1, 1);

        var dialog_content = get_content_area ();
        dialog_content.spacing = 5;
        dialog_content.append (stack_switcher);
        dialog_content.append (grid);

        add_button (_("Cancel"), Gtk.ResponseType.CLOSE);
        var add = add_button (_("Add Secret"), Gtk.ResponseType.APPLY);
        add.add_css_class ("suggested-button");

        response.connect (id => {
            if (id == Gtk.ResponseType.CLOSE) {
                destroy ();
            }
            else if (id == Gtk.ResponseType.APPLY) {
                var should_copy_pass = new Settings ("com.github.z0o0p.alohomora").get_boolean ("copy-new-pass");
                var display = Gdk.Display.get_default ();
                var clipboard = display.get_clipboard ();
                if (stack.visible_child_name == "Generate" && gen_pass.text != "") {
                    secret.new_secret.begin (credential_name.text, username.text, gen_pass.text);
                    if (should_copy_pass) {
                        clipboard.set_text (gen_pass.text);
                    }
                }
                else if (stack.visible_child_name == "Existing" && exist_pass.text != "") {
                    secret.new_secret.begin (credential_name.text, username.text, exist_pass.text);
                    if (should_copy_pass) {
                        clipboard.set_text (exist_pass.text);
                    }
                }
            }
        });

        secret.changed.connect (() => destroy ());
    }
}
