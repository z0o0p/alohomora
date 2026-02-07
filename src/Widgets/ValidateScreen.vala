/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.ValidateScreen: Gtk.Box {
    public Alohomora.SecretManager secret {get; construct;}

    private bool is_valid_input;
    private bool is_matching_key_input;
    private bool is_secure_key_input;

    private bool is_new_user;
    private string user_real_name;
    private Gtk.Box message;
    private Gtk.Box cipher;
    private Gtk.Entry key_entry;
    private Gtk.Entry re_key_entry;
    private Gtk.Button submit;

    public ValidateScreen (Alohomora.SecretManager secret_manager) {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 0,
            margin_top: 15,
            margin_bottom: 15,
            margin_start: 35,
            margin_end: 35,
            secret: secret_manager
        );
    }

    construct {
        is_new_user = new Settings ("io.github.z0o0p.alohomora").get_boolean ("new-user");
        user_real_name = GLib.Environment.get_real_name ();

        var wizard_art = new Gtk.Image.from_resource ("/io/github/z0o0p/alohomora/wizard.svg");
        wizard_art.vexpand = true;
        wizard_art.valign = Gtk.Align.CENTER;
        wizard_art.pixel_size = 128;

        var greet = new Gtk.Label (_("Welcome"));
        greet.add_css_class ("primary-text");
        var username = new Gtk.Label (user_real_name);
        username.add_css_class ("accent-bold-text");
        var text = new Gtk.Label ((is_new_user) ? _("Let's Get You Started") : _("I Need To Decipher Your Passwords First"));
        text.add_css_class ("primary-text");
        text.vexpand = true;
        text.valign = Gtk.Align.CENTER;
        var info = new Gtk.Label (_("Your new cipher key will be used to encipher all your saved passwords"));
        info.max_width_chars = 40;
        info.lines = 2;
        info.ellipsize = Pango.EllipsizeMode.END;
        info.justify = Gtk.Justification.CENTER;
        message = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        message.halign = Gtk.Align.CENTER;
        message.append (greet);
        message.append (username);
        message.append (text);
        if (is_new_user) {
            message.append (info);
        }

        var pass_strength_info_icon = new Gtk.Image.from_icon_name ("window-close-symbolic");
        var pass_strength_info_label = new Gtk.Label (_("Cipher key must be at least 8 characters"));
        pass_strength_info_label.hexpand = true;
        pass_strength_info_label.halign = Gtk.Align.START;
        var pass_strength_info = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        pass_strength_info.opacity = 0;
        pass_strength_info.append (pass_strength_info_icon);
        pass_strength_info.append (pass_strength_info_label);
        var pass_match_info_icon = new Gtk.Image.from_icon_name ("window-close-symbolic");
        var pass_match_info_label = new Gtk.Label (_("Key and reentered value must match"));
        pass_match_info_label.hexpand = true;
        pass_match_info_label.halign = Gtk.Align.START;
        var pass_match_info = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        pass_match_info.opacity = 0;
        pass_match_info.append (pass_match_info_icon);
        pass_match_info.append (pass_match_info_label);

        var key_label = new Gtk.Label (_("Enter Cipher Key:"));
        key_label.halign = Gtk.Align.START;
        key_entry = new Gtk.Entry ();
        key_entry.visibility = false;
        key_entry.secondary_icon_name = "eye-open-negative-filled-symbolic";
        key_entry.secondary_icon_tooltip_text = _("Show Cipher Key");
        key_entry.icon_press.connect (() => {
            key_entry.visibility = !key_entry.visibility;
            key_entry.secondary_icon_name = ((key_entry.visibility) ? "eye-not-looking-symbolic" : "eye-open-negative-filled-symbolic");
            key_entry.secondary_icon_tooltip_text = ((key_entry.visibility) ? _("Hide Cipher Key") : _("Show Cipher Key"));
        });
        key_entry.activate.connect (() => submit_key ());
        key_entry.changed.connect (() => {
            validate_input ();
            pass_strength_info.opacity = 1;
            pass_match_info.opacity = 1;
            if (is_secure_key_input) {
                pass_strength_info_icon.icon_name = "object-select-symbolic";
            }
            else {
                pass_strength_info_icon.icon_name = "window-close-symbolic";
            }
            if (is_matching_key_input) {
                pass_match_info_icon.icon_name = "object-select-symbolic";
            }
            else {
                pass_match_info_icon.icon_name = "window-close-symbolic";
            }
            if (is_valid_input) {
                submit.sensitive = true;
                submit.add_css_class ("primary-background");
            }
            else {
                submit.sensitive = false;
                submit.remove_css_class ("primary-background");
            }
        });
        var re_key_label = new Gtk.Label (_("Re-Enter Cipher Key:"));
        re_key_label.halign = Gtk.Align.START;
        re_key_entry = new Gtk.Entry ();
        re_key_entry.visibility = false;
        re_key_entry.secondary_icon_name = "eye-open-negative-filled-symbolic";
        re_key_entry.secondary_icon_tooltip_text = _("Show Cipher Key");
        re_key_entry.icon_press.connect (() => {
            re_key_entry.visibility = !re_key_entry.visibility;
            re_key_entry.secondary_icon_name = ((re_key_entry.visibility) ? "eye-not-looking-symbolic" : "eye-open-negative-filled-symbolic");
            re_key_entry.secondary_icon_tooltip_text = ((re_key_entry.visibility) ? _("Hide Cipher Key") : _("Show Cipher Key"));
        });
        re_key_entry.activate.connect (() => submit_key ());
        re_key_entry.changed.connect (() => {
            validate_input ();
            if (is_matching_key_input) {
                pass_match_info_icon.icon_name = "object-select-symbolic";
            }
            else {
                pass_match_info_icon.icon_name = "window-close-symbolic";
            }
            if (is_valid_input) {
                submit.sensitive = true;
                submit.add_css_class ("primary-background");
            }
            else {
                submit.sensitive = false;
                submit.remove_css_class ("primary-background");
            }
        });

        cipher = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
        cipher.margin_top = 35;
        cipher.margin_bottom = 10;
        cipher.append (key_label);
        cipher.append (key_entry);
        if (is_new_user) {
            cipher.append (re_key_label);
            cipher.append (re_key_entry);
            cipher.append (pass_strength_info);
            cipher.append (pass_match_info);
        }

        submit = new Gtk.Button.with_label (_("Submit"));
        submit.sensitive = false;
        submit.valign = Gtk.Align.CENTER;
        submit.clicked.connect (() => submit_key ());

        append (wizard_art);
        append (message);
        append (cipher);
        append (submit);
    }

    private void validate_input () {
        is_valid_input = key_entry.text != "";
        is_secure_key_input = (key_entry.text.length / 8.0) >= 1.0;
        is_matching_key_input = key_entry.text == re_key_entry.text;
        if (is_new_user) is_valid_input = is_valid_input && is_matching_key_input && is_secure_key_input;
    }

    private void submit_key () {
        validate_input ();
        if (is_valid_input && is_new_user) {
            secret.create_cipher_key.begin (user_real_name, key_entry.text, re_key_entry.text);
        }
        else if (is_valid_input) {
            secret.lookup_cipher_key.begin (user_real_name, key_entry.text);
        }
    }
}
