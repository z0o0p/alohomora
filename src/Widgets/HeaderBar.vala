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

public class Alohomora.HeaderBar: Gtk.HeaderBar {
    public Alohomora.Window window {get; construct;}
    public Alohomora.SecretManager secret {get; construct;}

    private Granite.ModeSwitch dark_mode;
    private Gtk.Button add_secret;
    private Gtk.Box help_menu;
    private Gtk.ModelButton change_key;
    private Gtk.ModelButton quit;
    private Gtk.PopoverMenu popover;
    private Gtk.MenuButton help;
    private Gtk.Settings settings;
    private weak Gtk.IconTheme icon_theme;

    public HeaderBar (Alohomora.Window app_window, Alohomora.SecretManager secret_manager) {
        Object (
            title: _("Alohomora"),
            show_close_button: true,
            window: app_window,
            secret: secret_manager
        );
    }

    construct {
        icon_theme = Gtk.IconTheme.get_default ();
        icon_theme.add_resource_path ("/com/github/z0o0p/alohomora");
        settings = Gtk.Settings.get_default ();

        add_secret = new Gtk.Button ();
        add_secret.image = new Gtk.Image.from_icon_name ("add-icon", Gtk.IconSize.LARGE_TOOLBAR);
        add_secret.valign = Gtk.Align.CENTER;
        add_secret.tooltip_text = _("Add New Login");
        add_secret.clicked.connect (() => {
            var dialog = new Alohomora.NewSecret(window, secret);
            dialog.run();
        });

        dark_mode = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
        dark_mode.active = settings.gtk_application_prefer_dark_theme;
        dark_mode.primary_icon_tooltip_text = _("Light Theme");
        dark_mode.secondary_icon_tooltip_text = _("Dark Theme");
        dark_mode.valign = Gtk.Align.CENTER;
        dark_mode.bind_property ("active", settings, "gtk_application_prefer_dark_theme");

        change_key = new Gtk.ModelButton ();
        change_key.text = _("Change Cipher Key");
        //Show dialog to change cipher when clicked
        change_key.clicked.connect (() => print("Change Cipher Key"));

        quit = new Gtk.ModelButton ();
        quit.text = _("Quit");
        quit.clicked.connect (() => window.close());

        help_menu = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        help_menu.pack_start (change_key, false, false, 2);
        help_menu.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        help_menu.pack_start (quit, false, false, 2);

        popover = new Gtk.PopoverMenu ();
        popover.add (help_menu);

        help = new Gtk.MenuButton ();
        help.popover = popover;
        help.image = new Gtk.Image.from_icon_name ("help-icon", Gtk.IconSize.BUTTON);
        help.valign = Gtk.Align.CENTER;
        help.tooltip_text = _("Help");
        help.clicked.connect (() => popover.show_all());

        pack_start (add_secret);
        pack_end (help);
        pack_end (dark_mode);
    }
}
