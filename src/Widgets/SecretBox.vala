/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.SecretBox : Gtk.Frame {
    public Alohomora.Window window {get; construct;}
    public Alohomora.SecretManager secret {get; construct;}
    public Secret.Item secret_item {get; construct;}

    private string credentials_name;
    private string user_name;
    private string pin_status;
    private string user_pass;
    private Gtk.Button copy;

    public SecretBox (Alohomora.Window app_window, Alohomora.SecretManager secret_manager, Secret.Item secretitem) {
        Object (
            window: app_window,
            secret: secret_manager,
            secret_item: secretitem
        );
    }

    construct {
        load_secret_attributes ();

        var pin_secret = new Gtk.Button ();
        pin_secret.add_css_class (Granite.STYLE_CLASS_MENUITEM);
        pin_secret.label = (bool.parse (pin_status)) ? _("Unpin Secret") : _("Pin Secret");
        pin_secret.clicked.connect (() => {
            var new_pin_status = (bool.parse (pin_status)) ? "false" : "true";
            secret.edit_secret.begin (credentials_name, credentials_name, user_name, user_name, user_pass, new_pin_status);
        });
        var edit_secret = new Gtk.Button ();
        edit_secret.add_css_class (Granite.STYLE_CLASS_MENUITEM);
        edit_secret.label = _("Edit Secret");
        edit_secret.clicked.connect (() => {
            var dialog = new Alohomora.EditSecret (window, secret, secret_item);
            dialog.show ();
        });
        var delete_secret = new Gtk.Button ();
        delete_secret.add_css_class (Granite.STYLE_CLASS_MENUITEM);
        delete_secret.label = _("Delete Secret");
        delete_secret.clicked.connect (() => secret.delete_secret.begin (credentials_name, user_name));
        var more_menu = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        more_menu.append (pin_secret);
        more_menu.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        more_menu.append (edit_secret);
        more_menu.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        more_menu.append (delete_secret);
        var popover = new Gtk.Popover ();
        popover.add_css_class (Granite.STYLE_CLASS_MENU);
        popover.set_child (more_menu);
        var more = new Gtk.MenuButton ();
        more.popover = popover;
        more.primary = true;
        more.icon_name = "more-icon";
        more.tooltip_text = _("More");

        var credentialname = new Gtk.Label (credentials_name);
        credentialname.add_css_class ("header-text");
        credentialname.halign = Gtk.Align.START;
        var username = new Gtk.Label (user_name);
        username.halign = Gtk.Align.START;

        var copy_icon = new Gtk.Image.from_icon_name ("copy-icon");
        copy = new Gtk.Button.with_label (_("Copy Password"));
        copy.can_focus = false;
        copy.clicked.connect (() => {
            var clipboard = Gdk.Display.get_default ().get_clipboard ();
            clipboard.set_text (user_pass);
        });

        var data_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
        data_box.halign = Gtk.Align.START;
        data_box.append (credentialname);
        data_box.append (username);

        var copy_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        copy_box.hexpand = true;
        copy_box.halign = Gtk.Align.END;
        copy_box.append (copy_icon);
        copy_box.append (copy);

        var secret_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        secret_box.margin_top = 5;
        secret_box.margin_bottom = 5;
        secret_box.margin_start = 5;
        secret_box.margin_end = 10;
        secret_box.append (more);
        secret_box.append (data_box);
        secret_box.append (copy_box);

        set_child (secret_box);
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
