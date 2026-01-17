# Project name, Languages used and Version
project ('com.github.z0o0p.alohomora', 'vala', 'c', version: '1.3.0', meson_version: '>= 0.56.0')

# Executes build files in given directories
subdir ('src')
subdir ('po')
subdir ('data')

# Executable
executable (
    meson.project_name (),
    sources,
    alohomora_resources,
    dependencies: [
        dependency ('gtk4'),
        dependency ('granite-7'),
        dependency ('libsecret-1')
    ],
    install: true
)
