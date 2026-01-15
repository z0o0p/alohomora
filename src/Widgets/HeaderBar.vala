/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.HeaderBar: Gtk.Box {
    public Alohomora.Window window {get; construct;}
    public Alohomora.SecretManager secret {get; construct;}

    private Gtk.Button add_secret;
    private Gtk.Button search;
    private Gtk.Button preferences;
    private Gtk.Button change_key;
    private Gtk.Button quit;
    private Gtk.MenuButton help;

    public HeaderBar (Alohomora.Window app_window, Alohomora.SecretManager secret_manager) {
        Object (
            window: app_window,
            secret: secret_manager
        );
    }

    construct {
        var display = Gdk.Display.get_default ();
        var icon_theme = Gtk.IconTheme.get_for_display (display);
        icon_theme.add_resource_path ("/com/github/z0o0p/alohomora");

        add_secret = new Gtk.Button.from_icon_name ("add-icon");
        add_secret.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);
        add_secret.valign = Gtk.Align.CENTER;
        add_secret.tooltip_text = _("Add New Login");
        add_secret.sensitive = false;
        add_secret.clicked.connect (() => {
            var dialog = new Alohomora.NewSecret (window, secret);
            dialog.show ();
        });

        search = new Gtk.Button ();
        search.add_css_class (Granite.STYLE_CLASS_MENUITEM);
        search.label = _("Search");
        search.sensitive = false;
        search.clicked.connect (() => window.search_secret ());

        preferences = new Gtk.Button ();
        preferences.add_css_class (Granite.STYLE_CLASS_MENUITEM);
        preferences.label = _("Preferences");
        preferences.sensitive = false;
        preferences.clicked.connect (() => {
            var dialog = new Alohomora.Preferences (window, secret);
            dialog.show ();
        });

        change_key = new Gtk.Button ();
        change_key.add_css_class (Granite.STYLE_CLASS_MENUITEM);
        change_key.label = _("Change Cipher Key");
        change_key.sensitive = false;
        change_key.clicked.connect (() => {
            var dialog = new Alohomora.ChangeCipher (window, secret);
            dialog.show ();
        });

        quit = new Gtk.Button ();
        quit.add_css_class (Granite.STYLE_CLASS_MENUITEM);
        quit.label = _("Quit");
        quit.clicked.connect (() => window.close ());

        var help_menu = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        help_menu.append (search);
        help_menu.append (preferences);
        help_menu.append (change_key);
        help_menu.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        help_menu.append (quit);

        var popover = new Gtk.Popover ();
        popover.add_css_class (Granite.STYLE_CLASS_MENU);
        popover.set_child (help_menu);

        help = new Gtk.MenuButton ();
        help.popover = popover;
        help.primary = true;
        help.icon_name = "help-icon";
        help.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);
        help.valign = Gtk.Align.CENTER;
        help.tooltip_text = _("Help");

        var header_bar = new Gtk.HeaderBar ();
        header_bar.add_css_class ("theme");
        header_bar.hexpand = true;
        header_bar.show_title_buttons = true;
        header_bar.pack_start (add_secret);
        header_bar.pack_end (help);

        append (header_bar);

        secret.key_validated.connect ((is_validated) => {
            add_secret.sensitive = search.sensitive = preferences.sensitive = change_key.sensitive = is_validated;
        });
    }
}
