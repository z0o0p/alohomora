/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.Application: Gtk.Application {
    public Application () {
        Object (
          application_id: "com.github.z0o0p.alohomora",
          flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }

    protected override void activate () {
        var display = Gdk.Display.get_default ();
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/z0o0p/alohomora/styles/global.css");
        Gtk.StyleContext.add_provider_for_display (
            display,
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_SETTINGS
        );

        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });

        var window = new Alohomora.Window (this);
        window.present ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
