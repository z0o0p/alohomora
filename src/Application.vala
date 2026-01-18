/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.Application: Gtk.Application {
    private Alohomora.Window window;
    private Alohomora.SecretManager secret;
    private SimpleAction add_secret_action;
    private SimpleAction search_action;
    private SimpleAction preferences_action;
    private SimpleAction change_key_action;
    private SimpleAction quit_action;

    public Application () {
        Object (
          application_id: "io.github.z0o0p.alohomora",
          flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }

    protected override void startup () {
        Granite.init ();
        base.startup ();

        secret = new Alohomora.SecretManager ();
        secret.key_validated.connect ((is_validated) => {
            add_secret_action.set_enabled (is_validated);
            search_action.set_enabled (is_validated);
            preferences_action.set_enabled (is_validated);
            change_key_action.set_enabled (is_validated);
        });
        window = new Alohomora.Window (this, secret);

        init_style ();
        init_accels ();
    }

    protected override void activate () {
        window.present ();
    }

    private void init_style () {
        var display = Gdk.Display.get_default ();
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/io/github/z0o0p/alohomora/styles/global.css");
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
    }

    private void init_accels () {
        add_secret_action = new SimpleAction ("add-secret", null);
        add_secret_action.set_enabled (false);
        add_secret_action.activate.connect (() => {
            var dialog = new Alohomora.NewSecret (window, secret);
            dialog.show ();
        });
        search_action = new SimpleAction ("search", null);
        search_action.set_enabled (false);
        search_action.activate.connect (() => window.search_secret (true));
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
        quit_action.activate.connect (quit);

        add_action (add_secret_action);
        add_action (search_action);
        add_action (preferences_action);
        add_action (change_key_action);
        add_action (quit_action);

        set_accels_for_action ("app.add-secret", { "<Ctrl>n" });
        set_accels_for_action ("app.search", { "<Ctrl>f" });
        set_accels_for_action ("app.quit", { "<Ctrl>q" });
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
