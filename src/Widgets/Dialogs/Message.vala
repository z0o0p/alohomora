/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.Message: Gtk.Dialog {
    public string dialog_title {get; construct;}
    public string dialog_subtitle {get; construct;}
    public string dialog_icon {get; construct;}

    public Message (Alohomora.Window app_window, string title, string subtitle, string icon) {
        Object (
            title: "",
            transient_for: app_window,
            deletable: false,
            resizable: false,
            modal: true,
            dialog_title: title,
            dialog_subtitle: subtitle,
            dialog_icon: icon
        );
    }

    construct {
        var icon = new Gtk.Image.from_icon_name (dialog_icon);
        icon.pixel_size = 48;
        var title = new Gtk.Label (dialog_title);
        title.halign = Gtk.Align.START;
        title.add_css_class ("primary-text");
        var subtitle = new Gtk.Label (dialog_subtitle);
        subtitle.max_width_chars = 30;
        subtitle.lines = 2;
        subtitle.halign = Gtk.Align.START;
        subtitle.ellipsize = Pango.EllipsizeMode.END;
        subtitle.justify = Gtk.Justification.LEFT;

        var grid = new Gtk.Grid ();
        grid.row_spacing = 10;
        grid.column_spacing = 25;
        grid.halign = Gtk.Align.CENTER;
        grid.attach (icon, 0, 0, 1, 2);
        grid.attach (title, 1, 0, 1, 1);
        grid.attach (subtitle, 1, 1, 1, 1);

        var dialog_content = get_content_area ();
        dialog_content.margin_top = 15;
        dialog_content.margin_bottom = 15;
        dialog_content.margin_start = 15;
        dialog_content.margin_end = 15;
        dialog_content.append (grid);

        add_button (_("Close"), Gtk.ResponseType.CLOSE);

        response.connect (() => destroy ());
    }
}
