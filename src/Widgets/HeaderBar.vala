/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.HeaderBar: Gtk.Box {
    public Alohomora.Window window {get; construct;}
    public Alohomora.SecretManager secret {get; construct;}

    private Gtk.Button add_secret;
    private SimpleAction search_action;
    private SimpleAction preferences_action;
    private SimpleAction change_key_action;
    private SimpleAction quit_action;

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
        add_secret.tooltip_text = _("Add New Login");
        add_secret.sensitive = false;
        add_secret.clicked.connect (() => {
            var dialog = new Alohomora.NewSecret (window, secret);
            dialog.show ();
        });

        search_action = new SimpleAction ("search", null);
        search_action.set_enabled (false);
        search_action.activate.connect (() => window.search_secret ());
        preferences_action = new SimpleAction ("preferences", null);
        preferences_action.set_enabled (false);
        preferences_action.activate.connect (() => {
            var dialog = new Alohomora.Preferences (window, secret);
            dialog.show ();
        });
        change_key_action = new SimpleAction ("change-key", null);
        change_key_action.set_enabled (false);
        change_key_action.activate.connect (() => {
            var dialog = new Alohomora.ChangeCipher (window, secret);
            dialog.show ();
        });
        quit_action = new SimpleAction ("quit", null);
        quit_action.activate.connect (() => window.close ());

        var action_group = new GLib.SimpleActionGroup ();
        action_group.add_action (search_action);
        action_group.add_action (preferences_action);
        action_group.add_action (change_key_action);
        action_group.add_action (quit_action);
        this.insert_action_group ("help", action_group);

        var menu = new Menu ();
        var search_menu_item = new MenuItem (_("Search"), "help.search");
        search_menu_item.set_attribute_value ("hidden-when", "action-disabled");
        menu.append_item (search_menu_item);
        var preferences_menu_item = new MenuItem (_("Preferences"), "help.preferences");
        preferences_menu_item.set_attribute_value ("hidden-when", "action-disabled");
        menu.append_item (preferences_menu_item);
        var change_cipher_menu_item = new MenuItem (_("Change Cipher Key"), "help.change-key");
        change_cipher_menu_item.set_attribute_value ("hidden-when", "action-disabled");
        menu.append_item (change_cipher_menu_item);
        menu.append (_("Quit"), "help.quit");

        var popover_menu = new Gtk.PopoverMenu.from_model (menu);
        popover_menu.has_arrow = false;
        popover_menu.halign = Gtk.Align.END;
        popover_menu.position = Gtk.PositionType.BOTTOM;

        var help = new Gtk.MenuButton ();
        help.popover = popover_menu;
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
            add_secret.set_sensitive (is_validated);
            search_action.set_enabled (is_validated);
            preferences_action.set_enabled (is_validated);
            change_key_action.set_enabled (is_validated);
        });
    }
}
