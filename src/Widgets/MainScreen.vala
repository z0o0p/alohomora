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
    private Gtk.Button close_button;
    private List<unowned Secret.Item> secrets;
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
        close_button = new Gtk.Button.with_label (_("Close"));
        close_button.clicked.connect (() => {
            refresh_sub_screen ();
            search_bar.set_search_mode (false);
        });
        search_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        search_box.add (search_entry);
        search_box.add (search_button);
        search_box.add (close_button);

        search_bar = new Gtk.SearchBar ();
        search_bar.connect_entry (search_entry);
        search_bar.add (search_box);

        sub_screen = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        screen.add (search_bar);
        screen.add (sub_screen);

        secret.initialized.connect (() => {
            secrets = secret.get_secrets ();
            refresh_sub_screen ();
            add (screen);
        });

        secret.changed.connect (() => {
            secrets = secret.get_secrets ();
            refresh_sub_screen ();
        });

        secret.ordering_changed.connect (refresh_sub_screen);

        window.key_press_event.connect ((event) => {
            if (window.user_validated ()) {
                if (Gdk.keyval_name (event.keyval) == "Escape") {
                    refresh_sub_screen ();
                }
                else {
                    return search_bar.handle_event (event);
                }
            }
            return false;
        });

        window.search_secret.connect (() => {
            search_bar.set_search_mode (true);
        });

        welcome.activated.connect ((index) => {
            if (index == 0) {
                var dialog = new Alohomora.NewSecret (window, secret);
                dialog.run ();
            }
        });
    }

    private void refresh_sub_screen () {
        sub_screen.foreach ((widget) => sub_screen.remove (widget));
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
    }

    private void search_secret () {
        var search_found = false;
        sub_screen.foreach ((widget) => sub_screen.remove (widget));
        secrets.foreach ((secret_item) => {
            var attribute = secret_item.get_attributes ();
            if (attribute["credential-name"].up ().contains (search_entry.text.up ())) {
                search_found = true;
                sub_screen.add (new Alohomora.SecretBox (window, secret, secret_item));
            }
        });
        if (!search_found) {
            var result_label = new Gtk.Label(_("No matches found"));
            result_label.ypad = 10;
            sub_screen.add (result_label);
        }
        screen.show_all ();
    }
}
