/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.MainScreen: Gtk.Box {
    public Alohomora.Window window {get; construct;}
    public Alohomora.SecretManager secret {get; construct;}

    private Gtk.Box screen;
    private Gtk.Box pin_screen;
    private Gtk.Box sub_screen;
    private Gtk.Separator separator;
    private Gtk.SearchBar search_bar;
    private Gtk.SearchEntry search_entry;
    private List<unowned Secret.Item> secrets;
    private Granite.Placeholder welcome;

    public MainScreen (Alohomora.Window app_window, Alohomora.SecretManager secret_manager) {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 0,
            window: app_window,
            secret: secret_manager
        );
    }

    construct {
        screen = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        welcome = new Granite.Placeholder (_("No Passwords Found"));
        welcome.hexpand = true;
        welcome.vexpand = true;
        var add_secret = welcome.append_button (new ThemedIcon ("list-add"), _("Add Password"), _("Stores a new password securely"));
        add_secret.can_focus = false;
        add_secret.halign = Gtk.Align.CENTER;

        search_entry = new Gtk.SearchEntry ();
        search_entry.activate.connect (search_secret);
        var search_button = new Gtk.Button.with_label (_("Search"));
        search_button.add_css_class ("primary-background");
        search_button.clicked.connect (search_secret);
        var close_button = new Gtk.Button.with_label (_("Close"));
        close_button.clicked.connect (() => {
            refresh_screen ();
            search_bar.set_search_mode (false);
        });
        var search_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        search_box.append (search_entry);
        search_box.append (search_button);
        search_box.append (close_button);
        search_bar = new Gtk.SearchBar ();
        search_bar.connect_entry (search_entry);
        search_bar.set_child (search_box);

        separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.margin_top = 10;
        separator.margin_bottom = 10;

        pin_screen = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        sub_screen = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        screen.append (search_bar);
        screen.append (pin_screen);
        screen.append (sub_screen);

        secret.initialized.connect (() => {
            secrets = secret.get_secrets ();
            refresh_screen ();
            append (screen);
        });

        secret.changed.connect (() => {
            secrets = secret.get_secrets ();
            refresh_screen ();
        });

        secret.ordering_changed.connect (refresh_screen);

        window.search_secret.connect (() => {
            search_bar.set_search_mode (true);
        });

        add_secret.clicked.connect (() => {
            var dialog = new Alohomora.NewSecret (window, secret);
            dialog.show ();
        });
    }

    private void refresh_screen () {
        var pin_empty = true;
        while (pin_screen.get_first_child () != null) pin_screen.remove (pin_screen.get_first_child ());
        while (sub_screen.get_first_child () != null) sub_screen.remove (sub_screen.get_first_child ());
        secrets.sort (secret.compare_secrets);
        if (!new Settings ("com.github.z0o0p.alohomora").get_boolean ("sort-ascending")) {
            secrets.reverse ();
        }
        if (secrets.length () != 0) {
            secrets.foreach ((secret_item) => {
                var attribute = secret_item.get_attributes ();
                if (attribute["pinned"] == "false" || attribute["pinned"] == null) {
                    sub_screen.append (new Alohomora.SecretBox (window, secret, secret_item));
                }
                else {
                    pin_screen.append (new Alohomora.SecretBox (window, secret, secret_item));
                    pin_empty = false;
                }
            });
            if (!pin_empty) {
                pin_screen.append (separator);
            }
        }
        else {
            sub_screen.append (welcome);
        }
    }

    private void search_secret () {
        var search_found = false;
        while (pin_screen.get_first_child () != null) pin_screen.remove (pin_screen.get_first_child ());
        while (sub_screen.get_first_child () != null) sub_screen.remove (sub_screen.get_first_child ());
        secrets.foreach ((secret_item) => {
            var attribute = secret_item.get_attributes ();
            if (attribute["credential-name"].up ().contains (search_entry.text.up ())) {
                search_found = true;
                sub_screen.append (new Alohomora.SecretBox (window, secret, secret_item));
            }
        });
        if (!search_found) {
            var result_label = new Gtk.Label(_("No matches found"));
            sub_screen.append (result_label);
        }
    }
}
