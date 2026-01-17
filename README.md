# Alohomora

[![License](https://img.shields.io/badge/license-GPL%20v3.0-blue)](https://github.com/z0o0p/alohomora/blob/master/LICENSE)
[![CI](https://github.com/z0o0p/alohomora/actions/workflows/ci.yaml/badge.svg)](https://github.com/z0o0p/alohomora/actions/workflows/ci.yaml)
[![Open Issues](https://img.shields.io/github/issues/z0o0p/alohomora)](https://github.com/z0o0p/alohomora/issues)

Alohomora is a free and open-source password manager designed for elementary OS and built using Vala and Gtk. It manages your passwords in a user-friendly manner while ensuring security.

Alohomora leverages the libsecret-1 library package to store passwords securely into the device keyring.

![](data/screenshots/alohomora-screenshot.png)

## Get it from elementary OS AppCenter!

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.z0o0p.alohomora)

This app is available on the elementary OS AppCenter. Head over there to download and install Alohomora.

## Building and Installation

You can build and install Alohomora from the source. Ensure that you have the required dependencies installed.

### Required Dependencies

* meson
* valac 
* libgtk-4-dev
* libgranite-7-dev
* libsecret-1-dev

### Build, Install and Run

```bash
# Clone repository and build application
git clone https://github.com/z0o0p/alohomora.git && cd alohomora

# Install and run application
flatpak-builder build com.github.z0o0p.alohomora.yml --user --install --force-clean
```

## Contributions <3

Anyone willing to contribute to this project is most welcome. Please refer to the [contributing guidelines](https://github.com/z0o0p/alohomora/blob/master/CONTRIBUTING.md) to get started.
