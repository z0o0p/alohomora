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

public class Application: Gtk.Application {
    public Application () {
        Object (
          application_id: "com.github.z0o0p.alohomora",
          flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/z0o0p/alohomora/styles/global.css");
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_SETTINGS
        );

        var window = new Alohomora.Window (this);

        add_window (window);
    }
}
