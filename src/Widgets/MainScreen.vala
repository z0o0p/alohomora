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

    private Settings settings;
    private Gtk.Box screen;
    private Gtk.Box sub_screen;
    private Gtk.Box search_box;
    private Gtk.SearchBar search_bar;
    private Gtk.SearchEntry search_entry;
    private Gtk.Button search_button;
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
        settings = new Settings ("com.github.z0o0p.alohomora");
        screen = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        welcome = new Granite.Widgets.Welcome (_("No Passwords Found"), _("Add a new credential."));
        welcome.append ("list-add", _("Add Password"), _("Stores a new password securely."));
        welcome.get_button_from_index (0).can_focus = false;

        search_entry = new Gtk.SearchEntry ();
        search_entry.activate.connect (search_secret);
        search_button = new Gtk.Button.with_label (_("Search"));
        search_button.clicked.connect (search_secret);

        search_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        search_box.add (search_entry);
        search_box.add (search_button);

        search_bar = new Gtk.SearchBar ();
        search_bar.show_close_button = true;
        search_bar.connect_entry (search_entry);
        search_bar.add (search_box);

        screen.add (search_bar);

        sub_screen = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        secret.initialized.connect (() => {
            secrets = secret.get_secrets ();
            secrets.sort (secret.compare_secrets);
            if (!settings.get_boolean ("sort-ascending")) {
                secrets.reverse ();
            }
            if (secrets.length() != 0) {
                secrets.foreach ((secret_item) => sub_screen.add (new Alohomora.SecretBox (window, secret, secret_item)));
            }
            else {
                sub_screen.add (welcome);
            }
            screen.add (sub_screen);
            screen.show_all ();
            add (screen);
        });

        secret.changed.connect (() => {
            sub_screen.foreach ((widget) => sub_screen.remove (widget));
            secrets = secret.get_secrets ();
            secrets.sort (secret.compare_secrets);
            if (!settings.get_boolean ("sort-ascending")) {
                secrets.reverse ();
            }
            if (secrets.length () != 0) {
                secrets.foreach ((secret_item) => sub_screen.add (new Alohomora.SecretBox (window, secret, secret_item)));
            }
            else {
                sub_screen.add (welcome);
            }
            screen.show_all ();
        });

        secret.ordering_changed.connect (() => {
            secrets.sort (secret.compare_secrets);
            if (!settings.get_boolean ("sort-ascending")) {
                secrets.reverse ();
            }
            sub_screen.foreach ((widget) => sub_screen.remove (widget));
            secrets.foreach ((secret_item) => sub_screen.add (new Alohomora.SecretBox (window, secret, secret_item)));
            screen.show_all ();
        });

        welcome.activated.connect ((index) => {
            if (index == 0) {
                var dialog = new Alohomora.NewSecret (window, secret);
                dialog.run ();
            }
        });

        window.key_press_event.connect ((event) => {
            if (window.user_validated()) {
                return search_bar.handle_event (event);
            }
        });

        search_entry.focus_out_event.connect(() => {
            sub_screen.foreach ((widget) => sub_screen.remove (widget));
            secrets.foreach ((secret_item) => sub_screen.add (new Alohomora.SecretBox (window, secret, secret_item)));
            screen.show_all ();
            return false;
        });
    }

    private void search_secret () {
        sub_screen.foreach ((widget) => sub_screen.remove (widget));
        secrets.foreach ((secret_item) => {
            var attribute = secret_item.get_attributes ();
            if (attribute["credential-name"].up ().contains (search_entry.text.up ())) {
                sub_screen.add (new Alohomora.SecretBox (window, secret, secret_item));
            }
        });
        screen.show_all ();
    }
}
