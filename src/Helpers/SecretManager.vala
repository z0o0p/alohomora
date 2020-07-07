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

public class Alohomora.SecretManager: GLib.Object {
    private Secret.Collection collection;
    private List<Secret.Item> secrets;
    private string key;

    public signal void initialized ();
    public signal void changed ();
    public signal void key_validated (bool is_validated);
    public signal void key_changed (bool is_changed);

    construct {
        initialize_secrets.begin ();
    }

    private Secret.Schema secret_schema () {
        var schema = new Secret.Schema (
            "com.github.z0o0p.alohomora.secret", Secret.SchemaFlags.NONE,
            "credential-name", Secret.SchemaAttributeType.STRING,
            "user-name", Secret.SchemaAttributeType.STRING
        );
        return schema;
    }

    private Secret.Schema cipher_schema () {
        var schema = new Secret.Schema (
            "com.github.z0o0p.alohomora.cipher", Secret.SchemaFlags.NONE,
            "user-name", Secret.SchemaAttributeType.STRING
        );
        return schema;
    }

    private async void load_secrets () {
        secrets.foreach ((secret_item) => secrets.remove(secret_item));
        try {
            key = yield Secret.password_lookup (
                cipher_schema (),
                null,
                "user-name", GLib.Environment.get_real_name (),
                null
            );
            var is_loaded = yield collection.load_items(null);
            if (is_loaded) {
                var secret_items = collection.get_items();
                foreach(var item in secret_items) {
                    if(item.get_label() == "Alohomora Secret") {
                        secrets.append(item);
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
            var collections = service.get_collections ();
            foreach(var c in collections) {
                if(c.label == "Login" || c.label == "Alohomora") {
                    collection = c;
                    yield load_secrets ();
                    initialized ();
                    return;
                }
            }
            collection = yield Secret.Collection.create (
                service,
                "Alohomora",
                null,
                0,
                null
            );
            initialized ();
        }
        catch (Error err) {
            critical ("%s", err.message);
        }
    }

    public async void new_secret (string credential_name, string user_name, string user_pass) {
        var attributes = new HashTable<string,string> (str_hash, str_equal);
        attributes["credential-name"] = credential_name;
        attributes["user-name"] = user_name;
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
            critical("%s", err.message);
        }
    }

    public async void edit_secret (string old_credentialname, string new_credentialname, string old_username, string new_username, string old_pass, string new_pass) {
        var secret_items = collection.get_items ();
        foreach (var item in secret_items) {
            if (item.get_label() == "Alohomora Secret") {
                try {
                    var attributes = item.get_attributes();
                    if (attributes["credential-name"] == old_credentialname) {
                        if (attributes["user-name"] == old_username) {
                            attributes["credential-name"] = new_credentialname;
                            attributes["user-name"] = new_username;
                            yield item.set_attributes (secret_schema(), attributes, null);
                            var secret = Alohomora.CipherManager.encipher (new_pass, key);
                            yield item.set_secret (new Secret.Value(secret, secret.length, "text/plain"), null);
                            yield load_secrets ();
                            changed ();
                        }
                    }
                }
                catch (Error err) {
                    critical ("%s", err.message);
                }
            }
        }
    }

    public async void delete_secret (string credential_name, string user_name) {
        var secret_items = collection.get_items ();
        foreach (var item in secret_items) {
            if (item.get_label() == "Alohomora Secret") {
                try {
                    var attributes = item.get_attributes ();
                    if (attributes["credential-name"] == credential_name) {
                        if (attributes["user-name"] == user_name) {
                            var success = yield item.delete (null);
                            if (success) {
                                yield load_secrets ();
                                changed ();
                            }
                        }
                    }
                }
                catch(Error err) {
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

    public List<Secret.Item> get_secrets() {
        return secrets.copy();
    }

    public async void create_cipher_key (string user_name, string cipher_key) {
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
            key_validated (res);
        }
        catch (Error err) {
            warning ("%s", err.message);
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
            warning("%s", err.message);
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
            if(key == old_key) {
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
        catch(Error err) {
            warning("%s", err.message);
        }
    }
}
