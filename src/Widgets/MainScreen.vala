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
    private List<Secret.Item> secrets;
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
        welcome.get_button_from_index (0).can_focus = false;

        secret.initialized.connect (() => {
            secrets = secret.get_secrets ();
            if (secrets.length() != 0) {
                secrets.foreach ((secret_item) => screen.add (new Alohomora.SecretBox (window, secret, secret_item)));
            }
            else {
                screen.add (welcome);
            }
            screen.show_all ();
            add (screen);
        });

        secret.changed.connect (() => {
            screen.foreach ((widget) => screen.remove (widget));
            secrets = secret.get_secrets ();
            if (secrets.length () != 0) {
                secrets.foreach ((secret_item) => screen.add (new Alohomora.SecretBox (window, secret, secret_item)));
            }
            else {
                screen.add (welcome);
            }
            screen.show_all ();
        });

        secret.order.connect ((is_ascending) => {
            secrets.sort (secret.compare_secrets);
            if (!is_ascending) {
                secrets.reverse ();
            }
            screen.foreach ((widget) => screen.remove (widget));
            secrets.foreach ((secret_item) => screen.add (new Alohomora.SecretBox (window, secret, secret_item)));
            screen.show_all ();
        });

        welcome.activated.connect ((index) => {
            if (index == 0) {
                var dialog = new Alohomora.NewSecret (window, secret);
                dialog.run ();
            }
        });
    }
}
