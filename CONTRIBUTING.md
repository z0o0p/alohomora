# Contributing to Alohomora

Contributions to this repository are highly appreciated, but there are few things to keep in mind to ensure your code is consistent across the project.

## Getting Started

* Look for [issues](https://github.com/z0o0p/alohomora/issues) to work on, or [create](https://github.com/z0o0p/alohomora/issues/new) a new issue. Ensure that your issue is not similar to the existing ones.
* It is recommended that you share your approach by commenting on that issue beforehand.
* When ready to work, [fork](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) this repository to your account.

#### Development Setup

Run the setup script which will help you get started.

```bash
sudo bash setup/setup.sh
```

## Making Changes

* Please avoid working directly on the `master` branch. Fork from the `develop` branch and add your changes there instead.
* Follow the [code style](https://docs.elementary.io/develop/writing-apps/code-style) as recommended by elementary OS.
* Make commits after every logical unit.

#### Commit Message

Use clear and simple commit messages so anyone can understand your change on the first read. Follow this format:

```
TYPE(SCOPE) - MESSAGE
```

How to write it:

* **TYPE** tells what you did:
  * **Add** – new feature or file
  * **Fix** – bug fix
  * **Update** – small improvement or change
* **SCOPE** is optional and mentions the associated GitHub issue
* **MESSAGE** explains the change in one clear line

For example, `Fix(#18) - Add missing permissions to flatpak manifest`, or `Add - Hindi translations`.

## Submitting Changes

* Push your changes, and create a [pull request](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork) to the `develop` branch of the Alohomora repository.
* If required, please mention the associated issue and describe the changes/additions to the code base.
