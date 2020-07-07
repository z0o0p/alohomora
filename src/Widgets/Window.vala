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

public class Alohomora.Window: Gtk.ApplicationWindow {
    private Alohomora.SecretManager secret;
    private GLib.Settings settings;
    private Alohomora.HeaderBar header_bar;
    private Alohomora.ValidateScreen validate_screen;

    public Window (Application app) {
        Object (
            application: app,
            default_height: 575,
            default_width: 400,
            resizable: false
        );
    }

    construct {
        settings = new GLib.Settings ("com.github.z0o0p.alohomora");
        Gtk.Settings.get_default().gtk_application_prefer_dark_theme = settings.get_boolean("dark-mode");
        get_style_context ().add_class ("rounded");
        int window_x,window_y;
        settings.get ("window-pos", "(ii)", out window_x, out window_y);
        if (window_x != -1 && window_y != -1)
            move (window_x, window_y);
        else
            window_position = Gtk.WindowPosition.CENTER;

        secret = new Alohomora.SecretManager ();

        header_bar = new Alohomora.HeaderBar (this);
        set_titlebar (header_bar);

        validate_screen = new Alohomora.ValidateScreen ();

        add (validate_screen);
        show_all ();

        validate_screen.try_validating.connect ((name, key) => {
            if (key != "") {
                if(settings.get_boolean ("new-user"))
                    secret.create_cipher_key.begin (name, key);
                else
                    secret.lookup_cipher_key.begin (name, key);
            }
        });

        secret.key_validated.connect ((success) => print(success.to_string()));

        delete_event.connect (e => {
            int x,y;
            get_position (out x, out y);
            settings.set ("window-pos", "(ii)", x, y);
            settings.set_boolean ("dark-mode", Gtk.Settings.get_default ().gtk_application_prefer_dark_theme);
            return false;
        });
    }
}
