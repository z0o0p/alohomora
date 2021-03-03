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

public class Alohomora.SecretBox : Gtk.Frame {
    public Alohomora.Window window {get; construct;}
    public Alohomora.SecretManager secret {get; construct;}
    public Secret.Item secret_item {get; construct;}

    private string credentials_name;
    private string user_name;
    private string pin_status;
    private string user_pass;
    private Gtk.Box secret_box;
    private Gtk.Box data_box;
    private Gtk.Box copy_box;
    private Gtk.Box more_menu;
    private Gtk.MenuButton more;
    private Gtk.PopoverMenu popover;
    private Gtk.ModelButton pin_secret;
    private Gtk.ModelButton edit_secret;
    private Gtk.ModelButton delete_secret;
    private Gtk.Label credentialname;
    private Gtk.Label username;
    private Gtk.Image copy_icon;
    private Gtk.Button copy;

    public SecretBox (Alohomora.Window app_window, Alohomora.SecretManager secret_manager, Secret.Item secretitem) {
        Object (
            border_width: 5,
            window: app_window,
            secret: secret_manager,
            secret_item: secretitem
        );
    }

    construct {
        load_secret_attributes ();

        popover = new Gtk.PopoverMenu ();
        more_menu = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        pin_secret = new Gtk.ModelButton ();
        pin_secret.text = (bool.parse (pin_status)) ? _("Unpin Secret") : _("Pin Secret");
        pin_secret.clicked.connect (() => {
            var new_pin_status = (bool.parse (pin_status)) ? "false" : "true";
            secret.edit_secret.begin(credentials_name, credentials_name, user_name, user_name, user_pass, new_pin_status);
        });
        edit_secret = new Gtk.ModelButton ();
        edit_secret.text = _("Edit Secret");
        edit_secret.clicked.connect (() => {
            var dialog = new Alohomora.EditSecret (window, secret, secret_item);
            dialog.run ();
        });
        delete_secret = new Gtk.ModelButton ();
        delete_secret.text = _("Delete Secret");
        delete_secret.clicked.connect (() => secret.delete_secret.begin(credentials_name, user_name));
        more_menu.pack_start (pin_secret, false, false, 2);
        more_menu.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        more_menu.pack_start (edit_secret, false, false, 2);
        more_menu.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        more_menu.pack_start (delete_secret, false, false, 2);
        popover.add (more_menu);
        more = new Gtk.MenuButton ();
        more.popover = popover;
        more.image = new Gtk.Image.from_icon_name ("more-icon", Gtk.IconSize.BUTTON);
        more.relief = Gtk.ReliefStyle.NONE;
        more.can_focus = false;
        more.clicked.connect (() => popover.show_all ());

        credentialname = new Gtk.Label (credentials_name);
        credentialname.get_style_context ().add_class ("header-text");
        credentialname.halign = Gtk.Align.START;
        username = new Gtk.Label (user_name);
        username.halign = Gtk.Align.START;

        copy_icon = new Gtk.Image.from_icon_name ("copy-icon", Gtk.IconSize.BUTTON);
        copy = new Gtk.Button.with_label (_("Copy Password"));
        copy.can_focus = false;
        copy.clicked.connect (() => {
            var clipboard = Gtk.Clipboard.get_default (Gdk.Display.get_default());
            clipboard.clear ();
            clipboard.set_text (user_pass, user_pass.length);
        });

        data_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
        data_box.halign = Gtk.Align.START;
        data_box.pack_start (credentialname);
        data_box.pack_start (username);

        copy_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        copy_box.pack_start (copy_icon);
        copy_box.pack_start (copy);

        secret_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        secret_box.margin = 5;
        secret_box.pack_start (more, false, false, 0);
        secret_box.pack_start (data_box, true, true, 6);
        secret_box.pack_end (copy_box, false, false, 0);

        add (secret_box);
    }

    private void load_secret_attributes () {
        var secret_attributes = secret_item.get_attributes ();
        credentials_name = secret_attributes.get ("credential-name");
        user_name = secret_attributes.get ("user-name");
        pin_status = (secret_attributes.get ("pinned") == null) ? "false" : secret_attributes.get ("pinned");
        secret.load_secret_value.begin (
            secret_item,
            (obj, res) => {
                secret.load_secret_value.end (res, out user_pass);
                copy.tooltip_text = user_pass;
            }
        );
    }
}
