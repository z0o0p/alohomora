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

public class Alohomora.NewSecret: Gtk.Dialog {
    public Alohomora.SecretManager secret {get; construct;}

    private Gtk.Grid grid;
    private Gtk.Label credential_name_label;
    private Gtk.Entry credential_name;
    private Gtk.Label username_label;
    private Gtk.Entry username;
    private Gtk.Label generate_message;
    private Gtk.Grid pass_grid;
    private Gtk.Label pass_label;
    private Gtk.Entry pass;
    private Gtk.Stack stack;
    private Gtk.StackSwitcher stack_switcher;

    public NewSecret (Alohomora.Window app_window, Alohomora.SecretManager secret_manager) {
        Object (
            title: _("Add New Secret"),
            transient_for: app_window,
            deletable: false,
            resizable: false,
            modal: true,
            border_width: 10,
            secret: secret_manager
        );
    }

    construct {
        credential_name_label = new Gtk.Label (_("Name :"));
        credential_name_label.halign = Gtk.Align.END;
        credential_name = new Gtk.Entry();
        credential_name.placeholder_text = _("Eg. Github, Facebook, etc.");
        username_label = new Gtk.Label (_("Username :"));
        username_label.halign = Gtk.Align.END;
        username = new Gtk.Entry ();

        grid = new Gtk.Grid ();
        grid.row_spacing = 5;
        grid.column_spacing = 5;
        grid.halign = Gtk.Align.CENTER;
        grid.margin_top = 20;
        grid.attach (credential_name_label,     0, 0, 1, 1);
        grid.attach (credential_name,           1, 0, 1, 1);
        grid.attach (username_label, 0, 1 ,1, 1);
        grid.attach (username,       1, 1, 1, 1);

        pass_label = new Gtk.Label (_(" Password :"));
        pass_label.halign = Gtk.Align.END;
        pass = new Gtk.Entry ();
        pass.visibility = false;
        pass.caps_lock_warning = false;
        pass.secondary_icon_name = "image-red-eye-symbolic";
        pass.secondary_icon_tooltip_text = _("Show Password");
        pass.icon_press.connect (() => pass.visibility = !pass.visibility);
        pass_grid = new Gtk.Grid ();
        pass_grid.row_spacing = 5;
        pass_grid.column_spacing = 5;
        pass_grid.attach (pass_label, 0, 0, 1, 1);
        pass_grid.attach (pass,       1, 0, 1, 1);

        generate_message = new Gtk.Label (_("Your Password Will Be Auto-Generated"));

        stack = new Gtk.Stack ();
        stack.halign = Gtk.Align.CENTER;
        stack.margin_bottom = 20;
        stack.add_titled (generate_message, "Generate", _("Generate New Password"));
        stack.add_titled (pass_grid, "Existing", _("Use Existing Password"));
        stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.stack = stack;

        var dialog_content = get_content_area ();
        dialog_content.spacing = 5;
        dialog_content.pack_start (stack_switcher);
        dialog_content.pack_start (grid);
        dialog_content.pack_start (stack);
        dialog_content.show_all ();

        add_button (_("Cancel"), Gtk.ResponseType.CLOSE);
        var add = add_button (_("Add Secret"), Gtk.ResponseType.APPLY);
        add.get_style_context ().add_class ("suggested-button");

        response.connect (id => {
            if (id == Gtk.ResponseType.CLOSE) {
                destroy ();
            }
            else if (id == Gtk.ResponseType.APPLY) {
                if (stack.visible_child_name == "Existing" && credential_name.text != "" && username.text != "" && pass.text != "") {
                    secret.new_secret.begin (credential_name.text, username.text, pass.text);
                }
                else if (stack.visible_child_name == "Generate" && credential_name.text != "" && username.text != "") {
                    secret.new_secret.begin (credential_name.text, username.text, Alohomora.PasswordGenerator.generate());
                }
            }
        });

        secret.changed.connect (() => destroy ());
    }
}
