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

public class Alohomora.ChangeCipher: Gtk.Dialog {
    public Alohomora.SecretManager secret {get; construct;}

    private Gtk.Grid grid;
    private Gtk.Label warning;
    private Gtk.Label old_key_label;
    private Gtk.Entry old_key;
    private Gtk.Label new_key_label;
    private Gtk.Entry new_key;

    public ChangeCipher (Alohomora.Window app_window, Alohomora.SecretManager secret_manager) {
        Object (
            title: _("Change Cipher Key"),
            transient_for: app_window,
            deletable: false,
            resizable: false,
            modal: true,
            border_width: 10,
            secret: secret_manager
        );
    }

    construct {
        warning = new Gtk.Label (_("CHANGING THE CIPHER KEY WILL MAKE THE EXISTING SECRETS UNUSABLE"));
        warning.get_style_context ().add_class ("message-warning");
        warning.halign = Gtk.Align.CENTER;
        old_key_label = new Gtk.Label (_("Old Cipher Key:"));
        old_key_label.halign = Gtk.Align.START;
        old_key = new Gtk.Entry ();
        old_key.visibility = false;
        old_key.caps_lock_warning = false;
        old_key.secondary_icon_name = "image-red-eye-symbolic";
        old_key.secondary_icon_tooltip_text = _("Show Old Cipher Key");
        old_key.icon_press.connect (() => old_key.visibility = !old_key.visibility);
        new_key_label = new Gtk.Label (_("New Cipher Key:"));
        new_key_label.halign = Gtk.Align.START;
        new_key = new Gtk.Entry();
        new_key.visibility = false;
        new_key.caps_lock_warning = false;
        new_key.secondary_icon_name = "image-red-eye-symbolic";
        new_key.secondary_icon_tooltip_text = _("Show New Cipher Key");
        new_key.icon_press.connect (() => new_key.visibility = !new_key.visibility);
        new_key.activate.connect (() => secret.change_cipher_key.begin(GLib.Environment.get_real_name(), old_key.text, new_key.text));

        grid = new Gtk.Grid ();
        grid.column_spacing = 5;
        grid.row_spacing = 5;
        grid.margin = 15;
        grid.attach (warning,       0, 0, 3, 1);
        grid.attach (old_key_label, 0, 1, 1, 1);
        grid.attach (old_key,       1, 1, 2, 1);
        grid.attach (new_key_label, 0, 2, 1, 1);
        grid.attach (new_key,       1, 2, 2, 1);

        get_content_area ().pack_start (grid);
        get_content_area ().show_all ();

        add_button (_("Cancel"), Gtk.ResponseType.CLOSE);
        var add = add_button (_("Change Key"), Gtk.ResponseType.APPLY);
        add.get_style_context ().add_class ("discouraged-button");

        response.connect(id => {
            if(id == Gtk.ResponseType.CLOSE) {
                destroy ();
            }
            else if (id == Gtk.ResponseType.APPLY) {
                if(old_key.text != "" && new_key.text != "") {
                    secret.change_cipher_key.begin(GLib.Environment.get_real_name(), old_key.text, new_key.text);
                }
            }
        });

        secret.key_changed.connect((is_changed) => {
            if(is_changed) {
                destroy();
            }
        });
    }
}
