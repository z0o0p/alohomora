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
    private Gtk.Label pass_label;
    private Gtk.Entry gen_pass;
    private Gtk.Entry exist_pass;
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
        credential_name.placeholder_text = _("Eg. GitHub, Facebook, etc.");

        username_label = new Gtk.Label (_("Username :"));
        username_label.halign = Gtk.Align.END;
        username = new Gtk.Entry ();

        pass_label = new Gtk.Label (_("Password :"));
        pass_label.halign = Gtk.Align.END;
        gen_pass = new Gtk.Entry ();
        gen_pass.text = Alohomora.PasswordGenerator.generate ();
        gen_pass.caps_lock_warning = false;
        gen_pass.secondary_icon_name = "view-refresh-symbolic";
        gen_pass.secondary_icon_tooltip_text = _("Re-Generate Password");
        gen_pass.icon_press.connect (() => gen_pass.text = Alohomora.PasswordGenerator.generate ());
        exist_pass = new Gtk.Entry ();
        exist_pass.visibility = false;
        exist_pass.caps_lock_warning = false;
        exist_pass.secondary_icon_name = "image-red-eye-symbolic";
        exist_pass.secondary_icon_tooltip_text = _("Show Password");
        exist_pass.icon_press.connect (() => exist_pass.visibility = !exist_pass.visibility);

        stack = new Gtk.Stack ();
        stack.add_titled (gen_pass, "Generate", _("Auto-Generate Password"));
        stack.add_titled (exist_pass, "Existing", _("Use Existing Password"));
        stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
        stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.stack = stack;

        grid = new Gtk.Grid ();
        grid.row_spacing = 5;
        grid.column_spacing = 5;
        grid.halign = Gtk.Align.CENTER;
        grid.margin = 20;
        grid.attach (credential_name_label, 0, 0, 1, 1);
        grid.attach (credential_name,       1, 0, 1, 1);
        grid.attach (username_label,        0, 1 ,1, 1);
        grid.attach (username,              1, 1, 1, 1);
        grid.attach (pass_label,            0, 2, 1, 1);
        grid.attach (stack,                 1, 2, 1, 1);

        var dialog_content = get_content_area ();
        dialog_content.spacing = 5;
        dialog_content.pack_start (stack_switcher);
        dialog_content.pack_start (grid);
        dialog_content.show_all ();

        add_button (_("Cancel"), Gtk.ResponseType.CLOSE);
        var add = add_button (_("Add Secret"), Gtk.ResponseType.APPLY);
        add.get_style_context ().add_class ("suggested-button");

        response.connect (id => {
            if (id == Gtk.ResponseType.CLOSE) {
                destroy ();
            }
            else if (id == Gtk.ResponseType.APPLY) {
                if (stack.visible_child_name == "Generate" && gen_pass.text != "") {
                    secret.new_secret.begin (credential_name.text, username.text, gen_pass.text);
                }
                else if (stack.visible_child_name == "Existing" && exist_pass.text != "") {
                    secret.new_secret.begin (credential_name.text, username.text, exist_pass.text);
                }
            }
        });

        secret.changed.connect (() => destroy ());
    }
}
