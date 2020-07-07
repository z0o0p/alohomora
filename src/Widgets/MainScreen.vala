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

public class Alohomora.MainScreen: Gtk.ScrolledWindow {
    public Alohomora.Window window {get; construct;}
    public Alohomora.SecretManager secret {get; construct;}

    private Gtk.Box screen;
    private Granite.Widgets.Welcome welcome;

    public MainScreen (Alohomora.Window app_window, Alohomora.SecretManager secret_manager) {
        Object (
            vscrollbar_policy: Gtk.PolicyType.AUTOMATIC,
            hscrollbar_policy: Gtk.PolicyType.NEVER,
            window: app_window,
            secret: secret_manager
        );
    }

    construct {
        screen = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        welcome = new Granite.Widgets.Welcome (_("No Passwords Found"), _("Add a new credential."));
        welcome.append ("list-add", _("Add Password"), _("Stores a new password securely."));

        secret.initialized.connect (() => {
            var secrets = secret.get_secrets ();
            if (secrets.length() != 0) {
                secrets.foreach ((secret_item) => screen.add (create_secret_view (secret_item)));
            }
            else {
                screen.add (welcome);
            }
            screen.show_all ();
            add (screen);
        });

        secret.changed.connect (() => {
            screen.foreach ((widget) => screen.remove (widget));
            var secrets = secret.get_secrets ();
            if (secrets.length () != 0) {
                secrets.foreach ((secret_item) => screen.add (create_secret_view (secret_item)));
            }
            else {
                screen.add (welcome);
            }
            screen.show_all ();
        });

        welcome.activated.connect ((index) => {
            if (index == 0) {
                var dialog = new Alohomora.NewSecret (window, secret);
                dialog.run ();
            }
        });
    }

    private Gtk.Frame create_secret_view (Secret.Item secret_item) {
        var secret_attributes = secret_item.get_attributes ();
        var credentials_name = secret_attributes.get ("credential-name");
        var user_name = secret_attributes.get ("user-name");

        var secret_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        secret_box.margin = 5;

        var popover = new Gtk.PopoverMenu ();
        var more_menu = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        var edit_secret = new Gtk.ModelButton ();
        edit_secret.text = _("Edit Secret");
        edit_secret.clicked.connect (() => {
            var dialog = new Alohomora.EditSecret (window, secret, secret_item);
            dialog.run ();
        });
        var delete_secret = new Gtk.ModelButton ();
        delete_secret.text = _("Delete Secret");
        delete_secret.clicked.connect (() => {
            secret.delete_secret.begin(credentials_name, user_name);
        });
        more_menu.pack_start (edit_secret, false, false, 2);
        more_menu.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        more_menu.pack_start (delete_secret, false, false, 2);
        popover.add (more_menu);
        var more = new Gtk.MenuButton ();
        more.popover = popover;
        more.image = new Gtk.Image.from_icon_name ("more-icon", Gtk.IconSize.BUTTON);
        more.relief = Gtk.ReliefStyle.NONE;
        more.can_focus = false;
        more.clicked.connect (() => popover.show_all ());

        var credentialname = new Gtk.Label (credentials_name);
        credentialname.get_style_context ().add_class ("header-text");
        credentialname.halign = Gtk.Align.START;
        var username = new Gtk.Label (user_name);
        username.halign = Gtk.Align.START;

        var copy_icon = new Gtk.Image.from_icon_name ("copy-icon", Gtk.IconSize.BUTTON);
        var copy = new Gtk.Button.with_label (_("Copy Password"));
        copy.can_focus = false;
        copy.clicked.connect (() => {
            secret.load_secret_value.begin (
                secret_item,
                (obj, res) => {
                    string user_pass;
                    secret.load_secret_value.end (res, out user_pass);
                    var clipboard = Gtk.Clipboard.get_default (Gdk.Display.get_default());
                    clipboard.clear ();
                    clipboard.set_text (user_pass, user_pass.length);
                }
            );
        });

        var data_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
        data_box.halign = Gtk.Align.START;
        data_box.pack_start (credentialname);
        data_box.pack_start (username);

        var copy_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        copy_box.pack_start (copy_icon);
        copy_box.pack_start (copy);

        secret_box.pack_start (more, false, false, 0);
        secret_box.pack_start (data_box, true, true, 6);
        secret_box.pack_end (copy_box, false, false, 0);

        var frame = new Gtk.Frame (null);
        frame.border_width = 5;
        frame.add (secret_box);

        return frame;
    }
}
