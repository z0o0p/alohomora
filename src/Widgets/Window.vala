/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.Window: Gtk.ApplicationWindow {
    private Alohomora.SecretManager secret;
    private Alohomora.HeaderBar header_bar;
    private Alohomora.ValidateScreen validate_screen;
    private Alohomora.MainScreen main_screen;
    private Gtk.Stack stack;

    public signal void search_secret ();

    public Window (Application app) {
        Object (
            application: app,
            title: "Alohomora",
            default_height: 575,
            default_width: 400,
            resizable: false
        );
    }

    construct {
        secret = new Alohomora.SecretManager ();

        header_bar = new Alohomora.HeaderBar (this, secret);
        set_titlebar (header_bar);

        validate_screen = new Alohomora.ValidateScreen (secret);
        main_screen = new Alohomora.MainScreen (this, secret);

        var main_screen_scroll = new Gtk.ScrolledWindow ();
        main_screen_scroll.hscrollbar_policy = Gtk.PolicyType.NEVER;
        main_screen_scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
        main_screen_scroll.set_child (main_screen);

        stack = new Gtk.Stack ();
        stack.add_named (validate_screen, "ValidateScreen");
        stack.add_named (main_screen_scroll, "MainScreen");
        stack.transition_type = Gtk.StackTransitionType.CROSSFADE;

        set_child (stack);

        secret.key_validated.connect ((is_validated) => {
            if (is_validated) {
                stack.visible_child_name = "MainScreen";
                new Settings ("com.github.z0o0p.alohomora").set_boolean ("new-user", false);
            }
            else {
                message_dialog (
                    _("Incorrect Key"),
                    _("The cipher key entered is wrong. Check and try again"),
                    "dialog-error"
                );
            }
        });

        secret.key_mismatch.connect (() => {
            message_dialog (
                _("Key Mismatch"),
                _("Passwords entered do not match. Check and try again"),
                "dialog-error"
            );
        });

        secret.key_changed.connect ((is_changed) => {
            if (is_changed)
                message_dialog (
                    _("Successful Change"),
                    _("Cipher key was successfully changed. Existing secrets are unusable now"),
                    "process-completed"
                );
            else {
                message_dialog (
                    _("Incorrect Key"),
                    _("The cipher key entered is wrong. Check and try again"),
                    "dialog-error"
                );
            }
        });
    }

    private void message_dialog (string title, string subtitle, string icon) {
        var dialog = new Alohomora.Message (this, title, subtitle, icon);
        dialog.show ();
    }

    public bool user_validated () {
        return stack.visible_child_name == "MainScreen";
    }
}
