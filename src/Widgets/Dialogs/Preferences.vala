/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.Preferences: Gtk.Dialog {
    public Alohomora.SecretManager secret {get; construct;}

    private Settings settings;
    private Gtk.DropDown sort;
    private Gtk.Switch copy;
    private Gtk.SpinButton pass_length;
    private Gtk.Switch include_special;
    private Gtk.Switch include_digit;

    public Preferences (Alohomora.Window app_window, Alohomora.SecretManager secret_manager) {
        Object (
            title: _("Preferences"),
            transient_for: app_window,
            deletable: false,
            resizable: false,
            modal: true,
            secret: secret_manager
        );
    }

    construct {
        settings = new Settings ("io.github.z0o0p.alohomora");

        var general_section_label = new Gtk.Label (_("General"));
        general_section_label.add_css_class ("primary-text");
        general_section_label.halign = Gtk.Align.START;

        var sort_label = new Gtk.Label (_("Sort Secrets By: "));
        sort_label.halign = Gtk.Align.END;
        sort = new Gtk.DropDown.from_strings ({_("Name, Ascending"), _("Name, Descending"), _("Date, Ascending"), _("Date, Descending")});
        var is_name_sort = (settings.get_string ("sort-parameter") == "name") ? 0 : 1;
        var is_ascending_sort = (settings.get_boolean ("sort-ascending")) ? 0 : 1;
        sort.selected = is_name_sort << 1 | is_ascending_sort;
        sort.width_request = 150;

        var copy_label = new Gtk.Label (_("Copy New Password After Adding: "));
        copy_label.halign = Gtk.Align.END;
        copy = new Gtk.Switch ();
        copy.halign = Gtk.Align.START;
        copy.valign = Gtk.Align.CENTER;
        copy.set_active (settings.get_boolean ("copy-new-pass"));

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.margin_top = 5;
        separator.margin_bottom = 5;

        var pass_section_label = new Gtk.Label (_("Password Generator"));
        pass_section_label.add_css_class ("primary-text");
        pass_section_label.halign = Gtk.Align.START;

        var include_digit_label = new Gtk.Label (_("Include Digits: "));
        include_digit_label.halign = Gtk.Align.END;
        include_digit = new Gtk.Switch ();
        include_digit.halign = Gtk.Align.START;
        include_digit.valign = Gtk.Align.CENTER;
        include_digit.set_active (settings.get_boolean ("include-digit"));

        var include_special_label = new Gtk.Label (_("Include Special Characters: "));
        include_special_label.halign = Gtk.Align.END;
        include_special = new Gtk.Switch ();
        include_special.halign = Gtk.Align.START;
        include_special.valign = Gtk.Align.CENTER;
        include_special.set_active (settings.get_boolean ("include-special"));

        var pass_length_label = new Gtk.Label (_("Generated Password Length: "));
        pass_length_label.halign = Gtk.Align.END;
        pass_length = new Gtk.SpinButton.with_range (8, 24, 1);
        pass_length.set_value (settings.get_int ("gen-pass-length"));

        var grid = new Gtk.Grid ();
        grid.row_spacing = 5;
        grid.column_spacing = 5;
        grid.halign = Gtk.Align.CENTER;
        grid.attach (general_section_label, 0, 0, 2, 1);
        grid.attach (sort_label,            0, 1, 1, 1);
        grid.attach (sort,                  1, 1, 1, 1);
        grid.attach (copy_label,            0, 2, 1, 1);
        grid.attach (copy,                  1, 2, 1, 1);
        grid.attach (separator,             0, 3, 2, 1);
        grid.attach (pass_section_label,    0, 4, 2, 1);
        grid.attach (pass_length_label,     0, 5, 1, 1);
        grid.attach (pass_length,           1, 5, 1, 1);
        grid.attach (include_special_label, 0, 6, 1, 1);
        grid.attach (include_special,       1, 6, 1, 1);
        grid.attach (include_digit_label,   0, 7, 1, 1);
        grid.attach (include_digit,         1, 7, 1, 1);

        var dialog_content = get_content_area ();
        dialog_content.margin_top = 15;
        dialog_content.margin_bottom = 15;
        dialog_content.margin_start = 15;
        dialog_content.margin_end = 15;
        dialog_content.append (grid);

        add_button (_("Close"), Gtk.ResponseType.CLOSE);
        var add = add_button (_("Apply"), Gtk.ResponseType.APPLY);
        add.add_css_class ("primary-background");

        response.connect (id => {
            if (id == Gtk.ResponseType.APPLY) {
                settings.set_boolean ("sort-ascending", ((sort.selected & 1) == 0));
                settings.set_string ("sort-parameter", (((sort.selected >> 1) & 1) == 0) ? "name" : "date");
                settings.set_boolean ("copy-new-pass", copy.active);
                settings.set_int ("gen-pass-length", (int) pass_length.value);
                settings.set_boolean ("include-special", include_special.active);
                settings.set_boolean ("include-digit", include_digit.active);
                secret.ordering_changed ();
            }
            destroy ();
        });
    }
}
