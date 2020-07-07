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

public class Alohomora.ValidateScreen: Gtk.Box {
    private bool newuser;
    private Gtk.Image wizard_art;
    private Gtk.Box message;
    private Gtk.Label greet;
    private Gtk.Label username;
    private Gtk.Label text;
    private Gtk.Label info;
    private Gtk.Box cipher;
    private Gtk.Label key_label;
    private Gtk.Entry key_entry;
    private Gtk.Button submit;

    public ValidateScreen () {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 0,
            margin_start: 40,
            margin_end: 40
        );
    }

    construct {
        newuser = new GLib.Settings ("com.github.z0o0p.alohomora").get_boolean ("new-user");

        wizard_art = new Gtk.Image.from_resource ("/com/github/z0o0p/alohomora/wizard.svg");
        wizard_art.vexpand = true;

        greet = new Gtk.Label (_("Welcome"));
        greet.get_style_context ().add_class ("message");
        username = new Gtk.Label (GLib.Environment.get_real_name ());
        username.get_style_context ().add_class ("message-name");
        text = new Gtk.Label ((newuser) ? _("Let's Get You Started") : _("I Need To Decipher Your Passwords First"));
        text.get_style_context ().add_class ("message");
        info = new Gtk.Label (_("Your new cipher key will be used to encipher all your saved passwords"));
        info.max_width_chars = 40;
        info.lines = 2;
        info.ellipsize = Pango.EllipsizeMode.END;
        info.justify = Gtk.Justification.CENTER;
        message = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        message.halign = Gtk.Align.CENTER;
        message.pack_start (greet);
        message.pack_start (username);
        message.pack_start (text, false, false, 25);
        if (newuser) {
            message.pack_start (info);
        }

        key_label = new Gtk.Label (_("Enter Cipher Key:"));
        key_label.halign = Gtk.Align.START;
        key_entry = new Gtk.Entry ();
        key_entry.visibility = false;
        key_entry.secondary_icon_name = "image-red-eye-symbolic";
        key_entry.secondary_icon_tooltip_text = _("Show Cipher Key");
        key_entry.icon_press.connect (() => key_entry.visibility = !key_entry.visibility);
        key_entry.activate.connect (() => print("Validating..."));
        cipher = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
        cipher.pack_start (key_label, false, false, 0);
        cipher.pack_start (key_entry, false, false, 0);

        submit = new Gtk.Button.with_label (_("Submit"));
        submit.clicked.connect(() => print("Validating..."));

        pack_start(wizard_art, false, false, 20);
        pack_start(message, false, false, 0);
        pack_start(cipher, true, false, 0);
        pack_start(submit, true, false, 5);
    }
}
