/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.SecretManager: GLib.Object {
    private Secret.Collection collection;
    private List<Secret.Item> secrets;
    private string key;

    public signal void initialized ();
    public signal void changed ();
    public signal void key_validated (bool is_validated);
    public signal void key_mismatch ();
    public signal void key_changed (bool is_changed);
    public signal void ordering_changed ();

    construct {
        initialize_secrets.begin ();
    }

    private Secret.Schema secret_schema () {
        var schema = new Secret.Schema (
            "io.github.z0o0p.alohomora.secret", Secret.SchemaFlags.NONE,
            "secret-id", Secret.SchemaAttributeType.STRING,
            "secret-type", Secret.SchemaAttributeType.STRING,
            "credential-name", Secret.SchemaAttributeType.STRING,
            "user-name", Secret.SchemaAttributeType.STRING,
            "pinned", Secret.SchemaAttributeType.BOOLEAN
        );
        return schema;
    }

    private Secret.Schema cipher_schema () {
        var schema = new Secret.Schema (
            "io.github.z0o0p.alohomora.cipher", Secret.SchemaFlags.NONE,
            "user-name", Secret.SchemaAttributeType.STRING
        );
        return schema;
    }

    private async void load_secrets () {
        secrets.foreach ((secret_item) => secrets.remove (secret_item));
        try {
            key = yield Secret.password_lookup (
                cipher_schema (),
                null,
                "user-name", GLib.Environment.get_real_name (),
                null
            );
            var is_loaded = yield collection.load_items(null);
            if (is_loaded) {
                var secret_items = collection.get_items ();
                foreach (var item in secret_items) {
                    if (item.get_label () == "Alohomora Secret") {
                        secrets.append (item);
                    }
                }
            }
        }
        catch (Error err) {
            critical ("%s", err.message);
        }
    }

    public async void initialize_secrets () {
        try{
            var service = yield Secret.Service.get (Secret.ServiceFlags.LOAD_COLLECTIONS, null);
            collection = yield Secret.Collection.for_alias (
                service,
                "default",
                Secret.CollectionFlags.LOAD_ITEMS,
                null
            );
            if (collection == null) {
                collection = yield Secret.Collection.create (
                    service,
                    "Login",
                    "default",
                    0,
                    null
                );
            }
            else {
                if (collection.get_locked ()) {
                    var objects = new GLib.List<GLib.DBusProxy> ();
		            objects.prepend (collection);
		            GLib.List<GLib.DBusProxy> unlocked;
		            yield service.unlock (objects, null, out unlocked);
                }
                yield load_secrets ();
            }
            initialized ();
        }
        catch (Error err) {
            critical ("%s", err.message);
        }
    }

    public async void new_secret (string secret_type, string credential_name, string user_name, string user_pass) {
        var attributes = new HashTable<string,string> (str_hash, str_equal);
        attributes["secret-id"] = new GLib.DateTime.now_utc ().to_unix ().to_string ();
        attributes["secret-type"] = secret_type;
        attributes["credential-name"] = credential_name;
        attributes["user-name"] = user_name;
        attributes["pinned"] = "false";
        try {
            var secret = Alohomora.CipherManager.encipher (user_pass, key);
            yield Secret.Item.create (
                collection,
                secret_schema (),
                attributes,
                "Alohomora Secret",
                new Secret.Value (secret, secret.length, "text/plain"),
                Secret.ItemCreateFlags.REPLACE,
                null
            );
            yield load_secrets ();
            changed ();
        }
        catch (Error err) {
            critical ("%s", err.message);
        }
    }

    public async void edit_secret (string secret_id, string new_credential_name, string new_username, string new_pass, string new_pin_status) {
        var secret_items = collection.get_items ();
        foreach (var item in secret_items) {
            if (item.get_label () == "Alohomora Secret") {
                try {
                    var attributes = item.get_attributes ();
                    if (attributes["secret-id"] == secret_id) {
                        attributes["credential-name"] = new_credential_name;
                        attributes["user-name"] = new_username;
                        attributes["pinned"] = new_pin_status;
                        yield item.set_attributes (secret_schema(), attributes, null);
                        var secret = Alohomora.CipherManager.encipher (new_pass, key);
                        yield item.set_secret (new Secret.Value (secret, secret.length, "text/plain"), null);
                        yield load_secrets ();
                        changed ();
                        break;
                    }
                }
                catch (Error err) {
                    critical ("%s", err.message);
                }
            }
        }
    }

    public async void delete_secret (string secret_id) {
        var secret_items = collection.get_items ();
        foreach (var item in secret_items) {
            if (item.get_label () == "Alohomora Secret") {
                try {
                    var attributes = item.get_attributes ();
                    if (attributes["secret-id"] == secret_id) {
                        var success = yield item.delete (null);
                        if (success) {
                            yield load_secrets ();
                            changed ();
                            break;
                        }
                    }
                }
                catch (Error err) {
                    critical ("%s", err.message);
                }
            }
        }
    }

    public async void load_secret_value (Secret.Item secret, out string user_pass) {
        try {
            yield secret.load_secret (null);
            user_pass = Alohomora.CipherManager.decipher (secret.get_secret ().get_text (), key);
        }
        catch (Error err) {
            user_pass = "";
            critical ("%s", err.message);
        }
    }

    public List<unowned Secret.Item> get_secrets () {
        return secrets.copy ();
    }

    public CompareFunc<Secret.Item> compare_secrets = (secret1, secret2) => {
        var attribute1 = secret1.get_attributes ();
        var attribute2 = secret2.get_attributes ();
        return strcmp (attribute1["credential-name"].up (), attribute2["credential-name"].up ());
    };

    public async void create_cipher_key (string user_name, string cipher_key, string re_cipher_key) {
        if (cipher_key != re_cipher_key) {
            key_mismatch ();
        }
        else {
            try {
                var res = yield Secret.password_store (
                    cipher_schema (),
                    Secret.COLLECTION_DEFAULT,
                    "Alohomora Cipher",
                    cipher_key,
                    null,
                    "user-name", user_name,
                    null
                );
                key = cipher_key;
                key_validated (res);
            }
            catch (Error err) {
                warning ("%s", err.message);
            }
        }
    }

    public async void lookup_cipher_key (string user_name, string entered_cipher_key) {
        try {
            var key = yield Secret.password_lookup (
                cipher_schema (),
                null,
                "user-name", user_name,
                null
            );
            key_validated (entered_cipher_key == key);
        }
        catch (Error err) {
            warning ("%s", err.message);
        }
    }

    public async void change_cipher_key (string user_name, string old_key, string new_key) {
        try {
            var key = yield Secret.password_lookup (
                cipher_schema (),
                null,
                "user-name", user_name,
                null
            );
            if (key == old_key) {
                var res = yield Secret.password_store (
                    cipher_schema (),
                    Secret.COLLECTION_DEFAULT,
                    "Alohomora Cipher",
                    new_key,
                    null,
                    "user-name", user_name,
                    null
                );
                key_changed (res);
            }
            else {
                key_changed (false);
            }
        }
        catch (Error err) {
            warning ("%s", err.message);
        }
    }
}
