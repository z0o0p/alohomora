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
    private Gtk.Settings settings;
    private weak Gtk.IconTheme icon_theme;
    private Gtk.Button add_secret;
    private Gtk.PopoverMenu popover;
    private Gtk.Box help_menu;
    private Gtk.ModelButton change_key;
    private Gtk.ModelButton quit;
    private Gtk.MenuButton help;

    public HeaderBar (Alohomora.Window app_window) {
        Object (
            window: app_window,
            title: "Alohomora",
            show_close_button: true
        );
    }

    construct {
        settings = Gtk.Settings.get_default ();
        icon_theme = Gtk.IconTheme.get_default ();
        icon_theme.add_resource_path ("/com/github/z0o0p/alohomora");

        add_secret = new Gtk.Button ();
        add_secret.image = new Gtk.Image.from_icon_name ("add-icon", Gtk.IconSize.LARGE_TOOLBAR);
        add_secret.valign = Gtk.Align.CENTER;
        add_secret.tooltip_text = "Add New Login";
        add_secret.clicked.connect(() => print("Add New Login"));

        change_key = new Gtk.ModelButton();
        change_key.text = "Change Cipher Key";
        change_key.clicked.connect(() => print("Change Cipher Key"));

        quit = new Gtk.ModelButton();
        quit.text = "Quit";
        quit.clicked.connect(() => window.close());

        help_menu = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        help_menu.pack_start(change_key, false, false, 2);
        help_menu.pack_start(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
        help_menu.pack_start(quit, false, false, 2);

        popover = new Gtk.PopoverMenu();
        popover.add(help_menu);

        help = new Gtk.MenuButton();
        help.popover = popover;
        help.image = new Gtk.Image.from_icon_name("help-icon", Gtk.IconSize.SMALL_TOOLBAR);
        help.valign = Gtk.Align.CENTER;
        help.tooltip_text = "Help";
        help.clicked.connect(() => popover.show_all());

        pack_start(add_secret);
        pack_end(help);
    }
}
